module MontageRails
  class StudioResource
    def self.schema_definition
      {
        name: "studios",
        fields: [
          {
            name: "name",
            datatype: "text",
            indexed: false,
            required: true
          }
        ],
        links: {
          self: "http://testco.dev.montagehot.club/api/v1/schemas/studios/",
          query: "http://testco.dev.montagehot.club/api/v1/schemas/studios/query/",
          create_document: "http://testco.dev.montagehot.club/api/v1/schemas/studios/save/"
        }
      }
    end

    def self.to_hash
      {
        name: "Universal"
      }
    end

    def self.save_response
      {
        data: [
          {
            id: "19442e09-5c2d-4e5d-8f34-675570e81414",
            _meta: {
              modified: "2015-04-20T18:39:51.394Z",
              created: "2015-04-20T18:39:51.394Z"
            },
            name: "Universal"
          }
        ]
      }
    end

    def self.get_studio_response
      {
        data: {
          id: "19442e09-5c2d-4e5d-8f34-675570e81414",
          _meta: {
            modified: "2015-04-20T18:39:51.394Z",
            created: "2015-04-20T18:39:51.394Z"
          },
          name: "Universal"
        }
      }
    end
  end
end
