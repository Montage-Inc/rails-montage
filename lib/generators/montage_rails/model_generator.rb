class MontageRails::ModelGenerator < ::Rails::Generators::NamedBase
  source_root File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
  argument :attributes, :type => :array, :default => [], :banner => "field[:type][:index] field[:type][:index]"
  
  desc "Creates a MontageRails model, a testing resource, and tests"

  def create_model_file
    template "model.rb", File.join("app/models", class_path, "#{file_name}.rb")
  end

  def create_test_resource
    template "resource.rb", File.join("test/resources", class_path, "#{file_name}_resource.rb")
  end

  hook_for :test_framework

  protected

  def parent_class_name
    options[:parent] || "MontageRails::Base"
  end
end
