require 'faker'
class MontageRails::ModelGenerator < ::Rails::Generators::NamedBase
  source_root File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
  argument :attributes, :type => :array, :default => [], :banner => "field[:type][:index] field[:type][:index]"
  
  desc "Creates a MontageRails model, a testing resource, and tests"

  def create_model_file
    template "model.rb", File.join("app/models", class_path, "#{file_name}.rb")
  end

  def create_test_resource
    template "resource.rb", File.join("test/montage_resources", class_path, "#{file_name}_resource.rb")
  end

  def create_test_data
    template 'test_data.rb', File.join("test/montage_resources/test_data", class_path, "#{file_name}_test_data.yml") # TODO
  end

  hook_for :test_framework

  protected

  def random_for_type(type)
    case type
    when :integer
      Faker::Number.number(10)
    when :float
      Faker::Number.decimal(2, 3)
    when :text
      Faker::Lorem.words(10).join(' ')
    when :date
      Faker::Date.backward(14)
    when :time
      Faker::Time.between(2.days.ago, Time.now, :all)
    when :datetime
      Faker::Time.between(2.days.ago, Time.now, :all)
    when :numeric
      Faker::Number.number(10)
    else
      # TODO
    end
      
  end

  def parent_class_name
    options[:parent] || "MontageRails::Base"
  end
end
