require 'test_helper'
require 'montage_rails/relation'
require 'montage_rails/base'

class MontageRails::BaseTest < MiniTest::Test
  context "initialization" do
    should "initialize all the variables with nil when nothing is passed in" do
      VCR.use_cassette("movies", allow_playback_repeats: true) do
        @movie = Movie.new
      end

      assert_nil @movie.rank
      assert_nil @movie.rating
      assert_nil @movie.title
      assert_nil @movie.votes
      assert_nil @movie.year
    end

    should "initialize with the passed in parameters" do
      VCR.use_cassette("movies", allow_playback_repeats: true) do
        @movie = Movie.new(rank: 1, rating: 2.0, title: "Foo", votes: 1, year: 1983, studio_id: "19442e09-5c2d-4e5d-8f34-675570e81414")
      end

      assert_equal 1, @movie.rank
      assert_equal 2.0, @movie.rating
      assert_equal "Foo", @movie.title
      assert_equal 1, @movie.votes
      assert_equal 1983, @movie.year
    end

    should "set persisted to the value passed in if it is passed in" do
      VCR.use_cassette("movies", allow_playback_repeats: true) do
        @movie = Movie.new(persisted: true)
      end

      assert @movie.persisted?
    end

    should "default persisted to false" do
      VCR.use_cassette("movies", allow_playback_repeats: true) do
        @movie = Movie.new
      end

      assert !@movie.persisted?
    end
  end

  context "callbacks" do
    should "respond to the before_save callback and before_create callback when it's not persisted" do
      VCR.use_cassette("movies", allow_playback_repeats: true) do
        @movie = Movie.new(rank: 4, rating: 2.0, title: "The Jerk", votes: 500, year: 1984, studio_id: "19442e09-5c2d-4e5d-8f34-675570e81414")
      end

      VCR.use_cassette("save_movie", allow_playback_repeats: true) do
        @movie.save
      end

      assert_equal "FOO", @movie.before_save_var
      assert_equal "BAR", @movie.before_create_var
    end

    should "only call the before_create callback if the record is not persisted" do
      VCR.use_cassette("movies", allow_playback_repeats: true) do
        VCR.use_cassette("save_movie", allow_playback_repeats: true) do
          @movie = Movie.create(rank: 4, rating: 2.0, title: "The Jerk", votes: 500, year: 1984, studio_id: "19442e09-5c2d-4e5d-8f34-675570e81414")
        end
      end

      @movie.before_create_var = nil
      @movie.before_save_var = nil

      VCR.use_cassette("update_movie", allow_playback_repeats: true) do
        @movie.votes = 600
        @movie.save
      end

      assert_nil @movie.before_create_var
      assert_equal "FOO", @movie.before_save_var
    end

    should "call the before_create callback on creation" do
      VCR.use_cassette("movies", allow_playback_repeats: true) do
        VCR.use_cassette("save_movie", allow_playback_repeats: true) do
          @movie = Movie.create(rank: 4, rating: 2.0, title: "The Jerk", votes: 500, year: 1984, studio_id: "19442e09-5c2d-4e5d-8f34-675570e81414")
        end
      end

      assert_equal "BAR", @movie.before_create_var
    end

    should "respond to the after_save callback and after_create callback when it's not persisted" do
      VCR.use_cassette("movies", allow_playback_repeats: true) do
        @movie = Movie.new(rank: 4, rating: 2.0, title: "The Jerk", votes: 500, year: 1984, studio_id: "19442e09-5c2d-4e5d-8f34-675570e81414")
      end

      VCR.use_cassette("save_movie", allow_playback_repeats: true) do
        @movie.save
      end

      assert_equal "AFTER SAVE", @movie.after_save_var
      assert_equal "AFTER CREATE", @movie.after_create_var
    end

    should "only call the after_create callback if the record is not persisted" do
      VCR.use_cassette("movies", allow_playback_repeats: true) do
        VCR.use_cassette("save_movie", allow_playback_repeats: true) do
          @movie = Movie.create(rank: 4, rating: 2.0, title: "The Jerk", votes: 500, year: 1984, studio_id: "19442e09-5c2d-4e5d-8f34-675570e81414")
        end
      end

      @movie.after_create_var = nil
      @movie.after_save_var = nil

      VCR.use_cassette("update_movie", allow_playback_repeats: true) do
        @movie.votes = 600
        @movie.save
      end

      assert_nil @movie.after_create_var
      assert_equal "AFTER SAVE", @movie.after_save_var
    end

    should "call the after_create callback on creation" do
      VCR.use_cassette("movies", allow_playback_repeats: true) do
        VCR.use_cassette("save_movie", allow_playback_repeats: true) do
          @movie = Movie.create(rank: 4, rating: 2.0, title: "The Jerk", votes: 500, year: 1984, studio_id: "19442e09-5c2d-4e5d-8f34-675570e81414")
        end
      end

      assert_equal "AFTER CREATE", @movie.after_create_var
    end
  end

  context "delegation" do
    should "delegate the first query method called to a Relation object and return a relation" do
      VCR.use_cassette("movies", allow_playback_repeats: true) do
        assert_equal MontageRails::Relation, Movie.where(foo: "bar").class
        assert_equal MontageRails::Relation, Movie.limit(10).class
        assert_equal MontageRails::Relation, Movie.offset(10).class
        assert_equal MontageRails::Relation, Movie.order(foo: :asc).class
      end
    end

    should "create finder methods for all the column names" do
      VCR.use_cassette("movies", allow_playback_repeats: true) do
        assert Movie.respond_to?(:find_by_rank)
        assert Movie.respond_to?(:find_by_title)
        assert Movie.respond_to?(:find_by_votes)
        assert Movie.respond_to?(:find_by_id)
        assert Movie.respond_to?(:find_by_year)
        assert Movie.respond_to?(:find_by_rating)
      end
    end
  end

  context "column methods" do
    setup do
      VCR.use_cassette("movies", allow_playback_repeats: true) do
        @movie = Movie.new
      end
    end

    should "respond to method names that correspond to column names" do
      assert @movie.respond_to?(:rank)
      assert @movie.respond_to?(:rating)
      assert @movie.respond_to?(:title)
      assert @movie.respond_to?(:votes)
      assert @movie.respond_to?(:year)
    end
  end

  context ".has_many" do
    setup do
      VCR.use_cassette("movies", allow_playback_repeats: true) do
        VCR.use_cassette("save_movie", allow_playback_repeats: true) do
          @movie = Movie.create(rank: 4, rating: 2.0, title: "The Jerk", votes: 500, year: 1984, studio_id: "19442e09-5c2d-4e5d-8f34-675570e81414")
        end
      end

      VCR.use_cassette("create_actor", allow_playback_repeats: true) do
        @actor = Actor.create(name: "Steve Martin", movie_id: @movie.id)

      end

      VCR.use_cassette("create_orphaned_actor", allow_playback_repeats: true) do
        @actor2 = Actor.create(name: "Mark Hamill")
      end
    end

    should "define an instance method for the given table name" do
      assert @movie.respond_to?(:actors)

      VCR.use_cassette("get_actors", allow_playback_repeats: true) do
        assert_equal 1, @movie.actors.count
        assert_equal @actor.attributes, @movie.actors.first.attributes
      end
    end

    should "allow the resulting relation to be chainable" do
      VCR.use_cassette("get_actors", allow_playback_repeats: true) do
        VCR.use_cassette("get_actor", allow_playback_repeats: true) do
          assert_equal @actor.attributes, @movie.actors.where(name: "Steve Martin").first.attributes
        end
      end
    end
  end

  context ".belongs_to" do
    should "define an instance method for the given table name" do
      VCR.use_cassette("movies", allow_playback_repeats: true) do
        VCR.use_cassette("get_movie", allow_playback_repeats: true) do
          @movie = Movie.find_by_title("The Jerk")
        end
      end

      VCR.use_cassette("create_studio", allow_playback_repeats: true) do
        @studio = Studio.create(name: "Universal")
      end

      assert @movie.respond_to?(:studio)
      assert @movie.respond_to?(:studio=)

      VCR.use_cassette("get_studio", allow_playback_repeats: true ) do
        assert_equal @studio.attributes, @movie.studio.attributes
      end

      VCR.use_cassette("update_movie", allow_playback_repeats: true) do
        @movie.studio = @studio
        @movie.save

        VCR.use_cassette("get_studio", allow_playback_repeats: true) do
          assert_equal @studio.attributes, @movie.studio.attributes
        end
      end
    end
  end

  context ".columns" do
    should "retrieve the column names from the database if they have not been already" do
      VCR.use_cassette("movies", allow_playback_repeats: true) do
        Movie.columns.each_with_index do |column, index|
          assert_equal column.name, Movie.columns[index].name
          assert_equal column.type, Movie.columns[index].type
          assert_equal column.required, Movie.columns[index].required
        end
      end
    end

    should "not call out to the database if the columns have already been retrieved" do
      VCR.use_cassette("movies", allow_playback_repeats: true) do
        Movie.columns

        MontageRails.connection.expects(:schems).never

        Movie.columns
      end
    end
  end

  context ".create" do
    should "save a new object and return an instance of the class" do
      VCR.use_cassette("movies", allow_playback_repeats: true) do
        VCR.use_cassette("save_movie", allow_playback_repeats: true) do
          @movie = Movie.create(rank: 4, rating: 2.0, title: "The Jerk", votes: 500, year: 1984, studio_id: "19442e09-5c2d-4e5d-8f34-675570e81414")
        end
      end

      assert @movie.persisted?
      assert_equal 4, @movie.rank
      assert_equal 2.0, @movie.rating
      assert_equal "The Jerk", @movie.title
      assert_equal 500, @movie.votes
      assert_equal 1984, @movie.year
    end
  end

  context ".find_or_initialize_by" do
    context "when the document is found" do
      should "return an instance of the document" do
        VCR.use_cassette("movies", allow_playback_repeats: true) do
          VCR.use_cassette("query_movie_found", allow_playback_repeats: true) do
            @movie = Movie.find_or_initialize_by(title: "The Jerk")
          end
        end

        assert @movie.persisted?
        assert_equal 4, @movie.rank
        assert_equal 2.0, @movie.rating
        assert_equal "The Jerk", @movie.title
        assert_equal 600, @movie.votes
        assert_equal 1984, @movie.year
      end
    end

    context "when the document is not found" do
      should "return a new instance of the document" do
        VCR.use_cassette("movies", allow_playback_repeats: true) do
          VCR.use_cassette("query_movie_not_found", allow_playback_repeats: true) do
            @movie = Movie.find_or_initialize_by(title: "Foo")
          end
        end

        assert !@movie.persisted?
        assert_equal "Foo", @movie.title
      end
    end
  end

  context ".all" do
    setup do
      VCR.use_cassette("movies", allow_playback_repeats: true) do
        VCR.use_cassette("all_movies", allow_playback_repeats: true) do
          @movies = Movie.all
        end
      end
    end

    should "fetch all the movies" do
      refute @movies.empty?
    end
  end

  context ".column_names" do
    setup do
      VCR.use_cassette("movies", allow_playback_repeats: true) do
        @column_names = Movie.column_names
      end

      @expected = %w(id created_at updated_at studio_id rank rating title votes year)
    end

    should "return an array of strings that contains the column names" do
      assert_equal @expected, @column_names
    end
  end

  context "#inspect" do
    setup do
      VCR.use_cassette("movies", allow_playback_repeats: true) do
        @inspect = Movie.inspect
      end
    end

    should "return a Rails style formatted inspect string" do
      assert_equal "Movie(id: text, created_at: datetime, updated_at: datetime, studio_id: text, rank: numeric, rating: numeric, title: text, votes: numeric, year: numeric)", @inspect
    end
  end

  context "#attributes_valid?" do
    should "return false if there is an invalid attribute" do
      VCR.use_cassette("movies", allow_playback_repeats: true) do
        @movie = Movie.new(rank: nil, rating: 2.0, title: "Foo", votes: 1, year: 1983, studio_id: "19442e09-5c2d-4e5d-8f34-675570e81414")
      end

      assert !@movie.attributes_valid?
    end
  end

  context "#save" do
    context "when valid attributes are provided" do
      setup do
        VCR.use_cassette("movies", allow_playback_repeats: true) do
          @movie = Movie.new(rank: 4, rating: 2.0, title: "The Jerk", votes: 500, year: 1984, studio_id: "19442e09-5c2d-4e5d-8f34-675570e81414")
        end
      end

      should "successfully save the document, return a copy of itself, and set persisted to true" do
        VCR.use_cassette("save_movie", allow_playback_repeats: true) do
          @movie.save
        end

        assert @movie.persisted?
      end
    end

    context "when valid attributes are not provided" do
      setup do
        VCR.use_cassette("movies", allow_playback_repeats: true) do
          @movie = Movie.new
        end
      end

      should "not save the document and return nil" do
        VCR.use_cassette("save_movie", allow_playback_repeats: true) do
          @movie.save
        end

        assert !@movie.persisted?
      end
    end
  end

  context "#update_attributes" do
    setup do
      VCR.use_cassette("movies", allow_playback_repeats: true) do
        VCR.use_cassette("save_movie", allow_playback_repeats: true) do
          @movie = Movie.create(rank: 4, rating: 2.0, title: "The Jerk", votes: 500, year: 1984, studio_id: "19442e09-5c2d-4e5d-8f34-675570e81414")
        end
      end
    end

    context "when valid attributes are given" do
      should "update the attributes and return a copy of self" do
        VCR.use_cassette("update_movie", allow_playback_repeats: true) do
          @movie.update_attributes(votes: 600)
        end

        assert_equal 600, @movie.votes
      end
    end

    context "when invalid attributes are given" do
      should "not update any attributes and return false" do
        assert !@movie.update_attributes(votes: nil)

        assert_equal 500, @movie.votes
      end
    end

    context "when none of the attributes have changed" do
      should "not update the document" do
        MontageRails.connection.expects(:update_document).never
        @movie.update_attributes(rank: 4, rating: 2.0, title: "The Jerk", votes: 500, year: 1984, studio_id: "19442e09-5c2d-4e5d-8f34-675570e81414")
      end
    end

    context "when only one, unchanged attribute is passed in" do
      should "not update the document" do
        MontageRails.connection.expects(:update_document).never
        @movie.update_attributes(rank: 4)
      end
    end

    context "when two, unchanged attributes are passed in" do
      should "not update the document" do
        MontageRails.connection.expects(:update_document).never
        @movie.update_attributes(rank: 4, rating: 2.0)
      end
    end

    context "when data types passed in don't match" do
      should "not update the document" do
        MontageRails.connection.expects(:update_document).never
        @movie.update_attributes(rank: "4", rating: "2.0")
      end
    end
  end
end
