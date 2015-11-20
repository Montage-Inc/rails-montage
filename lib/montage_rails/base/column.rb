module MontageRails
  class Base
    class Column
      TYPE_MAP = {
        "integer" => Integer,
        "float" => Float,
        "text" => String,
        "date" => Date,
        "time" => Time,
        "datetime" => DateTime,
        "numeric" => Numeric
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

      # Determines if the string value passed in is an integer
      # Returns true or false
      #
      def is_i?(value)
        /\A\d+\z/ =~ value.to_s
      end

      # Determines if the string value passed in is a float
      # Returns true or false
      #
      def is_f?(value)
        /\A\d+\.\d+\z/ =~ value.to_s
      end

      def coerce(value)
        return nil unless value
        return value if value.is_a?(TYPE_MAP[type])

        if is_i?(value)
          coerce_to = Integer
        elsif is_f?(value)
          coerce_to = Float
        else
          coerce_to = TYPE_MAP[type]
        end

        Virtus::Attribute.build(coerce_to).coerce(value)
      end
    end
  end
end
