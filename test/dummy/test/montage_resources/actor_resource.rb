class ActorResource < MontageRails::ApplicationResource
  def self.schema_definition
    {
      name: "actors",
      fields: [
        {
          name: "movie_id",
          datatype: "text",
          indexed: false,
          required: false
        },
        {
          name: "name",
          datatype: "text",
          indexed: false,
          required: false
        },
      ],
      links: {
        self: "http://testco.dev.montagehot.club/api/v1/schemas/actors/",
        query: "http://testco.dev.montagehot.club/api/v1/schemas/actors/query/",
        create_document: "http://testco.dev.montagehot.club/api/v1/schemas/actors/save/"
      }
    }
  end
end
