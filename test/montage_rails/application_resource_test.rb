require 'test_helper'
require 'montage_rails/application_resource'

class MontageRails::ApplicationResourceTest < Minitest::Test

  context 'reading yaml data' do
    setup do
      @resource = MontageRails::ApplicationResource.new
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

  context 'find' do
    setup do
      @resource = MontageRails::ApplicationResource.new
      @resource.expects(:read_yaml).returns([
        {"id"=>1,"name"=>'wrong'},
        {"id"=>2,"name"=>'right'},
        {"id"=>3,"name"=>'extra_wrong'}
        ])
    end
    should 'retrieve an item by id' do
      assert_equal 'right', @resource.find(2)['name']
    end
  end

  context 'execute_filters' do
    setup do
      @resource = MontageRails::ApplicationResource.new
      @item1 = {"name"=>'foo', 'votes'=>1, 'id'=>1}
      @item2 = {"name"=>'bar', 'votes'=>5, 'id'=>2}
      @item3 = {"name"=>'foobar', 'votes'=>10, 'id'=>3}
      @resource.data = [ @item1, @item2, @item3]
    end

    should 'handle equal to relations' do
      @resource.params = {
        "$schema" => "movies",
        "$query" => [
          ["$filter", [
            ["name", "bar"]
          ]]
        ]
      }
      @resource.execute_filters
      assert_equal [@item2], @resource.data
    end

    should 'handle equal lt relations' do
      @resource.params = {
        "$schema" => "movies",
        "$query" => [
          ["$filter", [
            ["votes", ["$lt", 5]]
          ]]
        ]
      }
      @resource.execute_filters
      assert_equal [@item1], @resource.data
    end

    should 'handle equal lte relations' do
      @resource.params = {
        "$schema" => "movies",
        "$query" => [
          ["$filter", [
            ["votes", ["$lte", 5]]
          ]]
        ]
      }
      @resource.execute_filters
      assert_equal [@item1,@item2], @resource.data
    end

    should 'handle equal gt relations' do
      @resource.params = {
        "$schema" => "movies",
        "$query" => [
          ["$filter", [
            ["votes", ["$gt", 5]]
          ]]
        ]
      }
      @resource.execute_filters
      assert_equal [@item3], @resource.data
    end

    should 'handle equal gte relations' do
      @resource.params = {
        "$schema" => "movies",
        "$query" => [
          ["$filter", [
            ["votes", ["$gte", 5]]
          ]]
        ]
      }
      @resource.execute_filters
      assert_equal [@item2,@item3], @resource.data
    end

    should "handle in relations" do
      @resource.params = {
        "$schema" => "movies",
        "$query" => [
          ["$filter", [
            ["votes", ["$in", [1, 5]]]
          ]]
        ]
      }
      @resource.execute_filters
      assert_equal [@item1, @item2], @resource.data
    end
  end
end
