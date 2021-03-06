require 'json'

module MontageRails
  class Relation < Montage::Query
    attr_reader :klass, :response, :loaded

    alias_method :loaded?, :loaded

    delegate :connection, to: MontageRails
    delegate :cache, to: :klass
    delegate :count, :length, :last, :[], :any?, :each_with_index, to: :to_a
    delegate :map, :each, :sort_by, :find, :each_slice, to: :to_a

    def initialize(klass)
      super(schema: klass.table_name)
      @klass = klass
      @loaded = false
      @response = {}
    end

    # Support for WillPaginate and Kaminari, if it is defined. If not, returns self
    #
    def paginate(page = 1, per_page = 25)
      if Object.const_defined?("WillPaginate")
        WillPaginate::Collection.create(page, per_page, count) do |pager|
          pager.replace(self[pager.offset, pager.per_page]).to_a
        end
      elsif Object.const_defined?("Kaminari")
        Kaminari.paginate_array(self).page(page).per(per_page)
      else
        self
      end
    end

    # Just adds a limit of 1 to the query, and forces it to return a singular
    # resource
    #
    def first
      limit(1).to_a.first
    end

    # Check if a record within the current scope exists
    #
    def exists?
      to_a.any?
    end

    # Override the pluck method that resides in the Ruby Montage query object
    # To conform with Rails convention, this method should return an array of
    # the result set, not an array of the class instances
    #
    def pluck(column_name)
      merge_array(["$pluck", [column_name.to_s]])
      map { |r| r.send(column_name.to_sym) }
    end

    # Create a record based on the query relationship
    #
    def create(params)
      klass.create(params.merge(options["$query"]["$filter"]))
    end

    # Utility method to allow viewing of the result set in a console
    #
    def inspect
      to_a.inspect
    end

    # Checks to see if the relation is loadable
    # If we are in test or dev environment, this is always true, otherwise
    # it falls back to checking the loaded? instance variable
    #
    def loadable?
      %w(test development).include?(Rails.env) || !loaded?
    end

    # Returns the set of records if they have already been fetched, otherwise
    # gets the records and returns them
    #
    def to_a
      return @records unless loadable?

      @response = cache.get_or_set_query(klass, options) do
        connection.documents({ query: options })
      end

      @records = []

      if @response.success?
        records = @response.members.attributes["query"]

        records.each do |record|
          @records << klass.new(record.merge(persisted: true))
        end

        @loaded = true
      end

      @records
    end

    # Force reload of the record
    #
    def reload
      reset
      to_a
      self
    end

    # Reset the whole shebang
    #
    def reset
      cache.remove("#{klass}/#{options}")
      @records = []
      @loaded = nil
      self
    end
  end
end
