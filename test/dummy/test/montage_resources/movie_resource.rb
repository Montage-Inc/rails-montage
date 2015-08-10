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
        },
        {
          name: "rating",
          datatype: "numeric",
        },
        {
          name: "title",
          datatype: "text",
        },
        {
          name: "votes",
          datatype: "numeric",
        },
        {
          name: "year",
          datatype: "numeric",
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
