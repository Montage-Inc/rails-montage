module MontageRails
  class ActorResource
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
            required: true
          }
        ],
        links: {
          self: "http://testco.dev.montagehot.club/api/v1/schemas/actors/",
          query: "http://testco.dev.montagehot.club/api/v1/schemas/actors/query/",
          create_document: "http://testco.dev.montagehot.club/api/v1/schemas/actors/save/"
        }
      }
    end

    def self.steve_martin
      {
        movie_id: "69cc93af-1f0e-43bc-ac9a-19117111978e",
        name: "Steve Martin"
      }
    end

    def self.mark_hamill
      {
        movie_id: nil,
        name: "Mark Hamill"
      }
    end

    def self.save_steve_response
      {
        data: [
          {
            id: "2b427e93-4809-425b-a587-e309a4715e8f",
            _meta: {
              modified: "2015-04-20T18:39:53.628Z",
              created: "2015-04-20T18:39:53.628Z"
            },
            movie_id: "69cc93af-1f0e-43bc-ac9a-19117111978e",
            name: "Steve Martin"
          }
        ]
      }
    end

    def self.save_mark_response
      {
        data: [
          {
            id: "d8332c5b-71a9-423d-8bc8-9d956e7257a4",
            _meta: {
              modified: "2015-04-20T18:39:53.962Z",
              created: "2015-04-20T18:39:53.962Z"
            },
            movie_id: "",
            name: "Mark Hamill"
          }
        ]
      }
    end

    def self.query
      {
        filter: {
          movie_id: "69cc93af-1f0e-43bc-ac9a-19117111978e" ,
          name: "Steve Martin"
        },
        limit: 1
      }
    end

    def self.query_result
      {
        data: [
          {
            id: "2b427e93-4809-425b-a587-e309a4715e8f",
            _meta: {
              modified: "2015-04-20T18:39:53.628Z",
              created: "2015-04-20T18:39:53.628Z"
            },
            movie_id: "69cc93af-1f0e-43bc-ac9a-19117111978e",
            name: "Steve Martin"
          }
        ],
        cursors: {
          previous: nil,
          next: nil
        }
      }
    end

    def self.relation_query
      {
        filter: {
          movie_id: "69cc93af-1f0e-43bc-ac9a-19117111978e"
        }
      }
    end

    def self.relation_response
      {
        data: [
          {
            id: "2b427e93-4809-425b-a587-e309a4715e8f",
            _meta: {
              modified: "2015-04-20T18:39:53.628Z",
              created: "2015-04-20T18:39:53.628Z"
            },
            movie_id: "69cc93af-1f0e-43bc-ac9a-19117111978e",
            name: "Steve Martin"
          }
        ],
        cursors: {
          previous: nil,
          next: nil
        }
      }
    end

    def self.relation_first_query
      {
        filter: {
          movie_id: "69cc93af-1f0e-43bc-ac9a-19117111978e"
        },
        limit: 1
      }
    end
  end
end
