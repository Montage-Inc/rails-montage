module MontageRails
  class ApplicationResource
    def read_yaml
      YAML.load_file(class_to_filename)
    end

    def class_to_filename
      File.join(Rails.root, 'test','montage_resources','test_data',
        self.class.to_s.underscore+'_test_data.yml')
    end
  end
end