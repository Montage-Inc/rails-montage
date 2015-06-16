module MontageRails
  class MovieResource
    def self.schema_definition
      {
        name: "movies",
        fields: [
          {name: "studio_id", datatype: "text", indexed: false, required: false},
          {name: "rank", datatype: "numeric", indexed: false, required: true},
          {name: "rating", datatype: "numeric", indexed: false, required: true},
          {name: "title", datatype: "text", indexed: false, required: true},
          {name: "votes", datatype: "numeric", indexed: false, required: true},
          {name: "year", datatype: "numeric", indexed: false, required: true}
        ],
        links: {
          query: "http://testco.dev.montagehot.club/api/v1/schemas/movies/query/",
          self: "http://testco.dev.montagehot.club/api/v1/schemas/movies/",
          create_document: "http://testco.dev.montagehot.club/api/v1/schemas/movies/save/"
        }
      }
    end

    def self.to_hash
      {
        studio_id: "19442e09-5c2d-4e5d-8f34-675570e81414",
        rank: 4,
        rating: 2.0,
        title: "The Jerk",
        votes: 500,
        year: 1983
      }
    end

    def self.save_with_update_hash
      {
        id: nil,
        studio_id: "19442e09-5c2d-4e5d-8f34-675570e81414",
        rank: 4,
        rating: 2.0,
        title: "The Jerk",
        votes: 500,
        year: 1983
      }
    end

    def self.update_body
      [
        {
          id: "69cc93af-1f0e-43bc-ac9a-19117111978e",
          studio_id: "19442e09-5c2d-4e5d-8f34-675570e81414",
          rank: 4,
          rating: 2.0,
          title: "The Jerk",
          votes: 600,
          year: 1983
        }
      ]
    end

    def self.save_response
      {
        data: [
          {
            votes: 500,
            _meta: {
              modified: "2015-04-20T18:39:47.751Z",
              created: "2015-04-20T18:39:47.751Z"
            },
            rating: 2.0,
            year: 1983,
            id: "69cc93af-1f0e-43bc-ac9a-19117111978e",
            title:"The Jerk",
            rank: 4,
            studio_id: "19442e09-5c2d-4e5d-8f34-675570e81414"
          }
        ]
      }
    end

    def self.update_response
      {
        data: [
          {
            votes: 600,
            _meta: {
              modified: "2015-04-20T18:39:47.751Z",
              created: "2015-04-20T18:39:47.751Z"
            },
            rating: 2.0,
            year: 1983,
            id: "69cc93af-1f0e-43bc-ac9a-19117111978e",
            title:"The Jerk",
            rank: 4,
            studio_id: "19442e09-5c2d-4e5d-8f34-675570e81414"
          }
        ]
      }
    end

    def self.movie_query
      {
        filter: {
          title: "The Jerk"
        },
        limit: 1
      }
    end

    def self.movie_query_pluck
      {
        filter: {
          title: "The Jerk"
        },
        pluck: ["title"]
      }
    end

    def self.query_result
      {
        data: [
          {
            _meta: {
              modified: "2015-04-20T18:39:50.095Z",
              created: "2015-04-20T18:39:47.751Z"
            },
            votes: 600,
            rating: 2.0,
            year: 1983,
            id: "69cc93af-1f0e-43bc-ac9a-19117111978e",
            title: "The Jerk",
            rank: 4,
            studio_id: "19442e09-5c2d-4e5d-8f34-675570e81414"
          }
        ],
        cursors: {
          previous: nil,
          next: nil
        }
      }
    end

    def self.pluck_response
      {
        data: [
          {
            _meta: {
              modified: "2015-04-20T18:39:50.095Z",
              created: "2015-04-20T18:39:47.751Z"
            },
            title: "The Jerk",
          }
        ],
        cursors: {
          previous: nil,
          next: nil
        }
      }
    end

    def self.find_movie_query
      {
        filter: {
          title: "The Jerk"
        }
      }
    end

    def self.movie_not_found_query
      {
        filter: {
          title: "Foo"
        }
      }
    end

    def self.all_movies_query
      { filter: {} }
    end

    def self.gt_query
      {
        filter: {
          votes__gt: 900000
        }
      }
    end
  end
end
