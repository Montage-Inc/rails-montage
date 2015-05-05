require 'montage_rails/log_subscriber'
require 'montage_rails/relation'
require 'montage_rails/base/column'
require 'active_model'
require 'virtus'

module MontageRails
  class Base
    extend ActiveModel::Callbacks
    include ActiveModel::Model
    include Virtus.model

    define_model_callbacks :save, :create

    class << self
      # Delegates all of the relation methods to the class level object, so they can be called on the base class
      #
      delegate :limit, :offset, :order, :where, :first, to: :relation

      # Delegate the connection to the base module for ease of reference
      #
      delegate :connection, :notify, to: MontageRails

      cattr_accessor :table_name

      # Define a new instance of the query cache
      #
      def cache
        @cache ||= QueryCache.new
      end

      # Hook into the Rails logger
      #
      def logger
        @logger ||= Rails.logger
      end

      # Setup a class level instance of the MontageRails::Relation object
      #
      def relation
        @relation = Relation.new(self)
      end

      # Define a has_many relationship
      #
      def has_many(table)
        class_eval do
          define_method(table.to_s.tableize.to_sym) do
            table.to_s.classify.constantize.where("#{self.class.table_name.demodulize.underscore.singularize.foreign_key} = #{id}")
          end
        end
      end

      # Define a belongs_to relationship
      #
      def belongs_to(table)
        class_eval do
          define_method(table.to_s.tableize.singularize.to_sym) do
            table.to_s.classify.constantize.find_by_id(__send__(table.to_s.foreign_key))
          end

          define_method("#{table.to_s.tableize.singularize}=") do |record|
            self.__send__("#{table.to_s.foreign_key}=", record.id)
            self
          end
        end
      end

      # The pluralized table name used in API requests
      #
      def table_name
        self.name.demodulize.underscore.pluralize
      end

      # Redefine the table name
      #
      def set_table_name(value)
        instance_eval do
          define_singleton_method(:table_name) do
            value
          end
        end
      end

      alias_method :table_name=, :set_table_name

      # Returns an array of MontageRails::Base::Column's for the schema
      #
      def columns
        @columns ||= [].tap do |ary|
          response = connection.schema(table_name)

          return [] unless response.schema.respond_to?(:fields)

          ary << Column.new("id", "text", false)
          ary << Column.new("created_at", "datetime", false)
          ary << Column.new("updated_at", "datetime", false)

          response.schema.fields.each do |field|
            ary << Column.new(field["name"], field["datatype"], field["required"])

            instance_eval do
              define_singleton_method("find_by_#{field["name"]}") do |value|
                where("#{field["name"]} = '#{value}'").first
              end
            end
          end
        end
      end

      # Fetch all the documents
      #
      def all
        relation.to_a
      end

      # Find a record by the id
      #
      def find_by_id(value)
        response = cache.get_or_set_query(self, value) { connection.document(table_name, value) }

        if response.success?
          new(response.document.items.merge(persisted: true))
        else
          nil
        end
      end

      alias_method :find, :find_by_id

      # Find the record using the given params, or initialize a new one with those params
      #
      def find_or_initialize_by(params = {})
        return nil if params.empty?

        query = relation.where(params)

        response = cache.get_or_set_query(self, query) { connection.documents(table_name, query: query) }

        if response.success? && response.documents.any?
          new(attributes_from_response(response).merge(persisted: true))
        else
          new(params)
        end
      end

      # Returns an array of the column names for the table
      #
      def column_names
        columns.map { |c| c.name }
      end

      # Initialize and save a new instance of the object
      #
      def create(params = {})
        new(params).save
      end

      # Returns a string like 'Post id:integer, title:string, body:text'
      #
      def inspect
        if self == Base
          super
        else
          attr_list = columns.map { |c| "#{c.name}: #{c.type}" } * ', '
          "#{super}(#{attr_list})"
        end
      end

      def method_missing(method_name, *args, &block)
        __send__(:columns)

        if respond_to?(method_name.to_sym)
          __send__(method_name.to_sym, *args)
        else
          super(method_name, *args, &block)
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        __send__(:column_names).include?(method_name.to_s.split("_").first) || super(method_name, include_private)
      end

      def attributes_from_response(response)
        case response.members
        when Montage::Documents then response.documents.first.attributes
        when Montage::Document then response.document.attributes
        when Montage::Errors then raise MontageAPIError, "There was an error with the Montage API: #{response.errors.attributes}"
        when Montage::Error then raise MontageAPIError, "There was an error with the Montage API: #{response.error.attributes}"
        else raise MontageAPIError, "There was an error with the Montage API, please try again."
        end
      end
    end

    attr_accessor :persisted

    alias_method :persisted?, :persisted

    delegate :connection, :notify, to: MontageRails
    delegate :attributes_from_response, to: "self.class"

    def initialize(params = {})
      initialize_columns
      @persisted = params[:persisted] ? params[:persisted] : false
      @current_method = "Load"
      super(params)
    end

    # Save the record to the database
    #
    # Will return nil if the attributes are not valid
    #
    # Upon successful creation or update, will return an instance of self, otherwise returns nil
    #
    def save
      run_callbacks :save do
        return nil unless attributes_valid?

        if persisted?
          @current_method = "Update"

          response = notify(self) do
            connection.create_or_update_documents(self.class.table_name, [updateable_attributes(include_id: true)])
          end
        else
          @current_method = "Create"

          response = notify(self) do
            connection.create_or_update_documents(self.class.table_name, [updateable_attributes])
          end
        end

        if response.success?
          if persisted?
            initialize(attributes_from_response(response))
          else
            run_callbacks :create do
              initialize(attributes_from_response(response))
              @persisted = true
            end
          end

          self
        else
          response
        end
      end
    end

    # The bang method for save, which will raise an exception if saving is not successful
    #
    def save!
      unless save
        raise MontageAPIError, response.errors.attributes
      end
    end

    # Update the given attributes for the document
    #
    # Returns false if the given attributes aren't valid
    #
    # Returns a copy of self if updating is successful
    #
    def update_attributes(params)
      old_attributes = attributes.clone

      params.each do |key, value|
        if respond_to?(key.to_sym)
          coerced_value = column_for(key.to_s).coerce(value)
          send("#{key}=", coerced_value)
        end
      end

      return self if old_attributes == attributes

      if attributes_valid?
        @current_method = id.nil? ? "Create" : "Update"

        response = notify(self) do
          connection.create_or_update_documents(self.class.table_name, [updateable_attributes(include_id: !id.nil?)])
        end

        initialize(attributes_from_response(response))
        @persisted = true
        self
      else
        initialize(old_attributes)
        false
      end
    end

    # Destroy the copy of this record from the database
    #
    def destroy
      @current_method = "Delete"
      notify(self) { connection.delete_document(self.class.table_name, id) }

      @persisted = false
      self
    end

    # Reload the current document
    #
    def reload
      @current_method = "Load"

      response = notify(self) do
        connection.document(self.class.table_name, id)
      end

      initialize(attributes_from_response(response))
      @persisted = true
      self
    end

    def new_record?
      !persisted?
    end

    # Returns the Column class instance for the attribute passed in
    #
    def column_for(name)
      self.class.columns.select { |column| column.name == name }.first
    end

    # Performs a check to ensure that required columns have a value
    #
    def attributes_valid?
      attributes.each do |key, value|
        next unless column_class = column_for(key.to_s)
        return false unless column_class.value_valid?(value)
      end
    end

    # The attributes used to update the document
    #
    def updateable_attributes(include_id: false)
      include_id ? attributes.except(:created_at, :updated_at) : attributes.except(:created_at, :updated_at, :id)
    end

    # Required for notifications to work, returns a payload suitable
    # for the log subscriber
    #
    def payload
      {
        reql: reql_payload[@current_method],
        name: "#{self.class.name} #{@current_method}"
      }
    end

    # Returns an <tt>#inspect</tt>-like string for the value of the
    # attribute +attr_name+. String attributes are elided after 50
    # characters, and Date and Time attributes are returned in the
    # <tt>:db</tt> format. Other attributes return the value of
    # <tt>#inspect</tt> without modification.
    #
    #   person = Person.create!(:name => "David Heinemeier Hansson " * 3)
    #
    #   person.attribute_for_inspect(:name)
    #   # => '"David Heinemeier Hansson David Heinemeier Hansson D..."'
    #
    #   person.attribute_for_inspect(:created_at)
    #   # => '"2009-01-12 04:48:57"'
    #
    def attribute_for_inspect(attr_name)
      value = attributes[attr_name]

      if value.is_a?(String) && value.length > 50
        "#{value[0..50]}...".inspect
      elsif value.is_a?(Date) || value.is_a?(Time)
        %("#{value.to_s(:db)}")
      else
        value.inspect
      end
    end

    # Returns the contents of the record as a nicely formatted string.
    #
    def inspect
      attributes_as_nice_string = self.class.column_names.collect { |name|
        if attributes[name.to_sym] || new_record?
          "#{name}: #{attribute_for_inspect(name.to_sym)}"
        end
      }.compact.join(", ")
      "#<#{self.class} #{attributes_as_nice_string}>"
    end

  private


    def initialize_columns
      self.class.columns.each do |column|
        self.class.__send__(:attribute, column.name.to_sym, Column::TYPE_MAP[column.type])
      end
    end

    def reql_payload
      {
        "Load" => id,
        "Update" => "#{id}: #{updateable_attributes(include_id: true)}",
        "Create" => updateable_attributes,
        "Delete" => id,
        "Save" => updateable_attributes
      }
    end
  end
end
