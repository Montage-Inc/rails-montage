class StudioResource < MontageRails::ApplicationResource
  def self.schema_definition
    {
      name: "studios",
      fields: [
        {
          name: "name",
          datatype: "text",
        },
      ],
      links: {
        self: "http://testco.dev.montagehot.club/api/v1/schemas/studios/",
        query: "http://testco.dev.montagehot.club/api/v1/schemas/studios/query/",
        create_document: "http://testco.dev.montagehot.club/api/v1/schemas/studios/save/"
      }
    }
  end
end
