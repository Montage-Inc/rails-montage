class MovieResource < MontageRails::ApplicationResource
  def self.schema_definition
    {
      name: "movies",
      fields: [
        {
          name: "studio_id",
          datatype: "text",
        },
        {
          name: "rank",
          datatype: "numeric",
          required: true,
        },
        {
          name: "rating",
          datatype: "numeric",
          required: true,
        },
        {
          name: "title",
          datatype: "text",
          required: true,
        },
        {
          name: "votes",
          datatype: "numeric",
          required: true,
        },
        {
          name: "year",
          datatype: "numeric",
          required: true,
        },
      ],
      links: {
        self: "http://testco.dev.montagehot.club/api/v1/schemas/movies/",
        query: "http://testco.dev.montagehot.club/api/v1/schemas/movies/query/",
        create_document: "http://testco.dev.montagehot.club/api/v1/schemas/movies/save/"
      }
    }
  end
end
