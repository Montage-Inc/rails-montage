class TestModResource
  def self.schema_definition
    {
      name: "testmods",
      fields: [
        {
          name: "foo",
          datatype: "text",
        },
        {
          name: "bar",
          datatype: "number",
        },
      ],
      links: {
        self: "http://testco.dev.montagehot.club/api/v1/schemas/testmods/",
        query: "http://testco.dev.montagehot.club/api/v1/schemas/testmods/query/",
        create_document: "http://testco.dev.montagehot.club/api/v1/schemas/testmods/save/"
      }
    }
  end
end
