class FooBarResource < MontageRails::ApplicationResource
  def self.schema_definition
    {
      name: "foobars",
      fields: [
        {
          name: "foo",
          datatype: "text",
        },
        {
          name: "bar",
          datatype: "integer",
        },
        {
          name: "barfoo",
          datatype: "float",
        },
        {
          name: "datetime",
          datatype: "datetime",
        },
        {
          name: "time",
          datatype: "time",
        },
        {
          name: "numeric",
          datatype: "numeric",
        },
        {
          name: "fail",
          datatype: "failure",
        },
      ],
      links: {
        self: "http://testco.dev.montagehot.club/api/v1/schemas/foobars/",
        query: "http://testco.dev.montagehot.club/api/v1/schemas/foobars/query/",
        create_document: "http://testco.dev.montagehot.club/api/v1/schemas/foobars/save/"
      }
    }
  end
end
