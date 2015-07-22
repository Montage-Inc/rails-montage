module MontageRails
  class ApplicationResource
    def read_yaml(yaml)
      YAML.load(yaml)
    end
  end
end
