module MontageRails
  class ApplicationResource
    class << self
      def read_yaml
        YAML.load_file(class_to_filename)
      end

      def class_to_filename
        File.join(Rails.root, 'test','montage_resources','test_data',
          self.to_s.underscore.sub('_resource','')+'_test_data.yml')
      end
    end
  end
end