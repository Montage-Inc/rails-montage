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
      File.join(Rails.root, 'test','montage_resources','test_data',
        self.class.to_s.underscore.sub('_resource','')+'_test_data.yml')
    end

    def find(id)
      read_yaml.select{|item| item['id'] == id}.first
    end

    def query(params)
      @data = self.read_yaml
      @params = params
      execute_filters
      @data
    end

    def execute_filters
      return unless @params['filter']
      @params['filter'].each do |filter, value|
        key = filter.scan(/__(.+)/).last
        key = key.last if !key.nil? # key is either nil or an array of a single string, reduce that
        parameter = key.nil? ? filter : filter.chomp('__'+key)
        case key
        when 'ieq' #case insensitve equality
        when 'not' #not operator, field != value
        when 'contains' # value in field
        when 'icontains' # case insensitive version of contains
        when 'in' # field in value
        when 'notin' # field not in value
        when 'gt' # field > value
          @data = @data.select{ |item| item[parameter] > value}
        when 'gte' # field >= value
          @data = @data.select{ |item| item[parameter] >= value}
        when 'lt' # field < value
          @data = @data.select{ |item| item[parameter] < value}
        when 'lte' # field <= value
          @data = @data.select{ |item| item[parameter] <= value}
        when 'startswith' # field.startswith(value)
        when 'istartswith' # case-insensitive starts with
        when 'endswith' # field.endsswith(value)
        when 'iendswith' # case-insensitvie endswith
        else #default is the 'equal to' operator
          @data = @data.select{ |item| item[parameter]==value}
        end
      end
    end

    
  end
end