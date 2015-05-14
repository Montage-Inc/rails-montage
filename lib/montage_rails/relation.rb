require 'json'

module MontageRails
  class Relation < Montage::Query
    attr_reader :klass, :response, :loaded

    alias_method :loaded?, :loaded

    delegate :connection, to: MontageRails
    delegate :cache, to: :klass
    delegate :count, :length, :last, :[], :any?, :each_with_index, to: :to_a
    delegate :map, :select, :each, :sort_by, :find, :each_slice, to: :to_a

    def initialize(klass)
      super()
      @klass = klass
      @loaded = false
      @response = {}
    end

    # Support for WillPaginate, if it is defined. If not, returns self
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

    # Utility method to allow viewing of the result set in a console
    #
    def inspect
      to_a.inspect
    end

    # Returns the set of records if they have already been fetched, otherwise
    # gets the records and returns them
    #
    def to_a
      return @records if loaded?

      @response = cache.get_or_set_query(klass, query) do
        connection.documents(klass.table_name, query)
      end

      @records = []

      if @response.success?
        @response.members.each do |member|
          @records << klass.new(member.attributes.merge(persisted: true))
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
      cache.remove("#{klass}/#{query}")
      @records = []
      @loaded = nil
      self
    end
  end
end
