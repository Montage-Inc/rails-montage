require 'test_helper'
require 'montage_rails/base'
require 'montage_rails/relation'

class MontageRails::RelationTest < Minitest::Test
  context "#reset" do
    setup do
      VCR.use_cassette("movies", allow_playback_repeats: true) do
        VCR.use_cassette("query_movies", allow_playback_repeats: true) do
          @movie = MontageRails::Relation.new(Movie).where(name: "The Jerk").limit(1)
        end
      end
    end

    should "reset all the values" do
      @movie.reset

      assert !@movie.loaded?
    end

    should "only remove the query for that relation from the cache" do
      @movie.cache.get_or_set_query("foo", "bar") do
        "bar"
      end

      @movie.reset

      assert_nil @movie.cache.cache["Movie/{:filter=>{:name=>\"The Jerk\"}, :limit=>1}"]
      assert_equal "bar", @movie.cache.cache["foo/bar"]
    end
  end

  context "#reload" do
    setup do
      VCR.use_cassette("movies", allow_playback_repeats: true) do
        VCR.use_cassette("query_movies", allow_playback_repeats: true) do
          @movie = MontageRails::Relation.new(Movie).where(name: "The Jerk").limit(1)
        end
      end
    end

    should "reset the values and reload the relation" do
      VCR.use_cassette("query_movies", allow_playback_repeats: true) do
        VCR.use_cassette("movies", allow_playback_repeats: true) do
          @movie.reload
        end
      end

      assert !@movie.to_a.empty?
    end
  end

  context "#nillify" do
    setup do
      VCR.use_cassette("movies", allow_playback_repeats: true) do
        @relation = MontageRails::Relation.new(Movie)
      end
    end

    should "return the string if not empty" do
      assert_equal "foo", @relation.nillify("foo")
    end

    should "return nil if the string is empty" do
      assert_nil @relation.nillify("")
    end

    should "return the number if it is not zero" do
      assert_equal 9, @relation.nillify(9)
    end

    should "return nil if the number is zero" do
      assert_nil @relation.nillify(0)
    end
  end

  context "#limit" do
    setup do
      VCR.use_cassette("movies", allow_playback_repeats: true) do
        @relation = MontageRails::Relation.new(Movie)
      end

      @expected = { filter: {}, limit: 10 }
    end

    should "append the limit attribute to the relation body" do
      assert_equal @expected, @relation.limit(10).query
    end

    should "set the default to nil" do
      assert_equal({filter: {}, limit: nil}, @relation.limit.query)
    end
  end

  context "#offset" do
    setup do
      VCR.use_cassette("movies", allow_playback_repeats: true) do
        @relation = MontageRails::Relation.new(Movie)
      end

      @expected = { filter: {}, offset: 10 }
    end

    should "append the offset attribute to the relation body" do
      assert_equal @expected, @relation.offset(10).query
    end

    should "set the default to nil" do
      assert_equal({ filter: {}, offset: nil }, @relation.offset.query)
    end
  end

  context "#order" do
    setup do
      VCR.use_cassette("movies", allow_playback_repeats: true) do
        @relation = MontageRails::Relation.new(Movie)
      end

      @expected = { filter: {}, order: "foobar asc" }
    end

    should "append the order attribute to the relation body" do
      assert_equal @expected, @relation.order("foobar asc").query
    end

    should "set the default sort order to asc if not passed in" do
      assert_equal @expected, @relation.order("foobar").query
    end

    should "set the default to nil" do
      assert_equal({ filter: {}, order: nil }, @relation.order.query)
    end

    should "accept and properly parse a hash" do
      assert_equal @expected, @relation.order(foobar: :asc).query
    end
  end

  context "#to_json" do
    setup do
      VCR.use_cassette("movies", allow_playback_repeats: true) do
        @relation = MontageRails::Relation.new(Movie)
      end
    end

    should "parse the relation to a json format" do
      assert_equal "{\"filter\":{\"foo\":1.0,\"bar__gt\":2},\"order\":\"created_at desc\",\"limit\":10}", @relation.where(foo: 1.0).where("bar > 2").order(created_at: :desc).limit(10).to_json
    end
  end

  context "#to_a" do
    should "return the record set without a query if the records have already been fetched" do
      VCR.use_cassette("movies", allow_playback_repeats: true) do
        @relation = MontageRails::Relation.new(Movie)

        VCR.use_cassette("query_movies", allow_playback_repeats: true) do
          @r = @relation.where("votes > 900000")
          @r.to_a
        end
      end

      assert @r.loaded?
    end

    should "query the remote db and return the record set if the records have not already been fetched" do

      VCR.use_cassette("movies", allow_playback_repeats: true) do
        VCR.use_cassette("query_movies", allow_playback_repeats: true) do
          @movies = MontageRails::Relation.new(Movie).where("votes > 900000").to_a
        end
      end

      assert_equal 6, @movies.count
    end
  end
end
