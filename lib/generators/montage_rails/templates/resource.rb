<% module_namespacing do -%>
class <%= class_name %>Resource
  def self.schema_definition
    {
      name: "<%= class_name.downcase.pluralize %>",
      fields: [
      <% attributes.each do |attribute| -%>
  {
          name: "<%= attribute.name -%>",
          datatype: "<%= attribute.type -%>",
        },
      <% end -%>
],
      links: {
        self: "http://testco.dev.montagehot.club/api/v1/schemas/<%= class_name.downcase.pluralize %>/",
        query: "http://testco.dev.montagehot.club/api/v1/schemas/<%= class_name.downcase.pluralize %>/query/",
        create_document: "http://testco.dev.montagehot.club/api/v1/schemas/<%= class_name.downcase.pluralize %>/save/"
      }
    }
  end
end
<% end -%>
