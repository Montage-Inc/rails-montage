class TestModResource < MontageRails::ApplicationResource
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
          datatype: "numeric",
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
