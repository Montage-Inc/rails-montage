module MontageRails
  class ApplicationResource

    attr_accessor :params, :data

    def self.fetch_item
      self.new.read_yaml.first
    end

    def read_yaml
      YAML.load_file(class_to_filename)
    end

    def class_to_filename
      File.join(Rails.root, "test", "montage_resources", "test_data",
        "#{self.class.to_s.underscore.sub("_resource","")}_test_data.yml")
    end

    def find(id)
      read_yaml.select{|item| item["id"] == id}.first
    end

    def query(params)
      @data = self.read_yaml
      @params = params
      execute_filters
      @data
    end

    def execute_filters
      return unless @params["$query"] && @params["$schema"]
      @params["$query"][0][1].each do |filter|
        key = filter[0]
        operator = filter[1].is_a?(Array) ? filter[1][0] : filter[1]
        case operator
        when "ieq" #case insensitve equality
        when "not" #not operator, field != value
        when "contains" # value in field
        when "icontains" # case insensitive version of contains
        when "$in" # field in value
          @data = @data.select { |item| filter[1][1].include?(item[key]) }
        when "notin" # field not in value
        when "$gt" # field > value
          @data = @data.select{ |item| item[key] > filter[1][1] }
        when "$gte" # field >= value
          @data = @data.select{ |item| item[key] >= filter[1][1] }
        when "$lt" # field < value
          @data = @data.select{ |item| item[key] < filter[1][1] }
        when "$lte" # field <= value
          @data = @data.select{ |item| item[key] <= filter[1][1] }
        when "startswith" # field.startswith(value)
        when "istartswith" # case-insensitive starts with
        when "endswith" # field.endsswith(value)
        when "iendswith" # case-insensitvie endswith
        else #default is the 'equal to' operator
          @data = @data.select{ |item| filter[1] === item[key] }
        end
      end
    end
  end
end
