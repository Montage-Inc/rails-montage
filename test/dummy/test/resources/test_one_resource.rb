class TestOneResource
  def self.schema_definition
    {
      name: "testones",
      fields: [
        {
          name: "name",
          datatype: "text",
        },
        {
          name: "title",
          datatype: "text",
        },
        {
          name: "age",
          datatype: "number",
        },
      ],
      links: {
        self: "http://testco.dev.montagehot.club/api/v1/schemas/testones/",
        query: "http://testco.dev.montagehot.club/api/v1/schemas/testones/query/",
        create_document: "http://testco.dev.montagehot.club/api/v1/schemas/testones/save/"
      }
    }
  end
end
