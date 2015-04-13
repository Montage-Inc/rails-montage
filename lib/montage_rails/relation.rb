require 'json'

module MontageRails
  class Relation
    # Currently the Montage wrapper only supports the following operators
    #
    OPERATOR_MAP = {
      "=" => "",
      "!=" => "__not",
      ">" => "__gt",
      ">=" => "__gte",
      "<" => "__lt",
      "<=" => "__lte",
      "in" => "__in"
    }

    attr_reader :klass, :response, :query, :loaded

    alias_method :loaded?, :loaded

    delegate :connection, :cache, to: MontageRails
    delegate :each, :count, :length, :last, :[], :any?, :map, :each_with_index, to: :to_a

    def initialize(klass)
      @klass = klass
      @query = { filter: {} }
      @loaded = false
      @response = {}
    end

    # Support for WillPaginate, if it is defined. If not, returns self
    #
    def paginate(page: 1, per_page: 25)
      if Object.const_defined?("WillPaginate")
        WillPaginate::Collection.create(page, per_page, count) do |pager|
          pager.replace(self[pager.offset, pager.per_page]).to_a
        end
      else
        self
      end
    end

    # Defines the limit to apply to the query, defaults to nil
    #
    # Merges a hash:
    #  { limit: 10 }
    #
    # Returns a reference to self
    #
    def limit(max = nil)
      clone.tap { |r| r.query.merge!(limit: max) }
    end

    # Defines the offset to apply to the query, defaults to nil
    #
    # Merges a hash:
    #   { offset: 10 }
    #
    # Returns a reference to self
    #
    def offset(value = nil)
      clone.tap { |r| r.query.merge!(offset: value) }
    end

    # Defines the order clause for the query and merges it into the query hash
    #
    # Accepts either a string or a hash:
    #   order("foo asc") or
    #   order(:foo => :asc) or
    #   order(:foo => "asc")
    #
    # Defaults the direction to asc if no value is passed in for that, or if it is not a valid value
    #
    # Merges a hash:
    #   { order: "foo asc" }
    #
    # Returns a reference to self
    #
    def order(clause = {})
      if clause.is_a?(Hash)
        direction = clause.values.first.to_s
        field = clause.keys.first.to_s
      else
        direction = clause.split(" ")[1]
        field = clause.split(" ")[0]
        direction = "asc" unless %w(asc desc).include?(direction)
      end

      clone.tap{ |r| r.query.merge!(order: nillify("#{field} #{direction}".strip)) }
    end

    # Adds a where clause to the query filter hash
    #
    # Accepts either a Hash or a String
    #     where(foo: 1)
    #     where("foo > 1")
    #
    # Merges a hash:
    #   { foo: 1 }
    #
    # Returns a reference to self
    #
    def where(clause)
      clone.tap { |r| r.query[:filter].merge!(clause.is_a?(String) ? parse_string_clause(clause) : clause) }
    end

    # Just adds a limit of 1 to the query, and forces to return a singular resource
    #
    def first
      limit(1).to_a.first
    end

    def inspect
      to_a.inspect
    end

    # Fetch all the documents
    #
    def all
      @query = {}
      to_a
    end

    # Returns the set of records if they have already been fetched, otherwise gets the records and returns them
    #
    def to_a
      return @records if loaded?

      @response = cache.get_or_set_query(klass, query) { connection.documents(klass.table_name, query: query) }

      @records = []

      if @response.success?
        @response.members.each do |member|
          @records << klass.new(member.attributes.merge(persisted: true))
        end

        @loaded = true
      end

      @records
    end

    # Will take either an empty string or zero and turn it into a nil object
    # If the value passed in is neither zero or an empty string, will return the value
    #
    def nillify(value)
      return value unless ["", 0].include?(value)
      nil
    end

    # Determines if the string value passed in is an integer
    # Returns true or false
    #
    def is_i?(value)
      /\A\d+\z/ === value
    end

    # Determines if the string value passed in is a float
    # Returns true or false
    #
    def is_f?(value)
      /\A\d+\.\d+\z/ === value
    end

    # Parses the query string value into an integer, float, or string
    #
    def parse_value(value)
      if is_i?(value)
        value.to_i
      elsif is_f?(value)
        value.to_f
      else
        value.gsub(/('|\(|\))/, "")
      end
    end

    # Parses the SQL string passed into the method
    #
    # Raises an exception if it is not a valid query (at least three "words"):
    #   parse_string_clause("foo bar")
    #
    # Raises an exception if the operator given is not a valid operator
    #   parse_string_clause("foo * 'bar'")
    #
    # Returns a hash:
    #   parse_string_clause("foo <= 1")
    #   => { foo__lte: 1.0 }
    #
    def parse_string_clause(clause)
      split = clause.split(" ")
      raise RelationError, "Your relation has an undetermined error" unless split.count >= 3

      operator = OPERATOR_MAP[split[1].downcase]
      raise RelationError, "The operator you have used is not a valid Montage relation operator" unless operator

      value = parse_value(split.select.with_index { |value, i| i >= 2 }.join(" "))

      { "#{split[0]}#{operator}".to_sym => value }
    end

    # Parses the current query hash and returns a JSON string
    #
    def to_json
      @query.to_json
    end
  end
end