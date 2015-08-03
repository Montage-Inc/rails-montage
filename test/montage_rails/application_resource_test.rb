require 'test_helper'
require 'montage_rails/application_resource'

class MontageRails::ApplicationResourceTest < Minitest::Test
  context 'reading yaml data' do
    setup do
      @resource = MontageRails::ApplicationResource
    end
    should 'generate filename from class' do
      expected = File.join(Rails.root, 'test','montage_resources','test_data',
        'montage_rails','application_test_data.yml')
      assert_equal expected, @resource.class_to_filename
    end
    should 'call class_to_filename when loading YAML' do
      filename='some_string'
      @resource.expects(:class_to_filename).returns(filename)
      YAML.stubs(:load_file)
      @resource.read_yaml
    end
    should 'use class_to_filename when calling YAML' do
      filename='some_string'
      @resource.stubs(:class_to_filename).returns(filename)
      YAML.expects(:load_file).with(filename)
      @resource.read_yaml
    end
    should 'return yaml load data' do
      data = { "some_data"=>"New Data"}
      filename='some_string'
      @resource.stubs(:class_to_filename).returns(filename)
      YAML.stubs(:load_file).with(filename).returns(data)
      assert_equal @resource.read_yaml, data
    end
  end
end
