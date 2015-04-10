module MontageRails
  class Base
    class Column
      TYPE_MAP = {
        "integer" => Integer,
        "float" => Float,
        "text" => String,
        "date" => Date,
        "time" => Time,
        "datetime" => DateTime
      }

      attr_accessor :name, :type, :required

      alias_method :required?, :required

      def initialize(name, type, required = false)
        @name = name
        @type = type
        @required = required
      end

      def value_valid?(value)
        !(required? && value.nil?)
      end
    end
  end
end