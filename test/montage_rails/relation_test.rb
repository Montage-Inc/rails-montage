require 'test_helper'
require 'montage_rails/base'
require 'montage_rails/relation'

class MontageRails::RelationTest < Minitest::Test
  class Movie < MontageRails::Base

  end

  context "initialization" do

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

  context "#is_i?" do
    setup do
      VCR.use_cassette("movies", allow_playback_repeats: true) do
        @relation = MontageRails::Relation.new(Movie)
      end
    end

    should "return false if a float is passed in" do
      assert !@relation.is_i?("1.2")
    end

    should "return false if a string is passed in" do
      assert !@relation.is_i?("foo")
    end

    should "return true if an integer is passed in" do
      assert @relation.is_i?("1")
    end
  end

  context "#is_f?" do
    setup do
      VCR.use_cassette("movies", allow_playback_repeats: true) do
        @relation = MontageRails::Relation.new(Movie)
      end
    end

    should "return false if an integer is passed in" do
      assert !@relation.is_f?("1")
    end

    should "return false if a string is passed in" do
      assert !@relation.is_f?("foo")
    end

    should "return true if a float is passed in" do
      assert @relation.is_f?("1.2")
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

  context "#parse_value" do
    setup do
      VCR.use_cassette("movies", allow_playback_repeats: true) do
        @relation = MontageRails::Relation.new(Movie)
      end
    end

    should "return an integer if the value is an integer" do
      assert_equal 1, @relation.parse_value("1")
    end

    should "return a float if the value is a float" do
      assert_equal 1.2, @relation.parse_value("1.2")
    end

    should "return a sanitized string if the value is a string" do
      assert_equal "foo", @relation.parse_value("'foo'")
    end
  end

  context "#parse_string_clause" do
    setup do
      VCR.use_cassette("movies", allow_playback_repeats: true) do
        @relation = MontageRails::Relation.new(Movie)
      end
    end

    should "raise an exception if the relation string doesn't have the right number of values" do
      assert_raises(MontageRails::RelationError, "Your relation has an undetermined error") do
        @relation.parse_string_clause("foo")
      end
    end

    should "raise an exception if none of the operators match" do
      assert_raises(MontageRails::RelationError, "The operator you have used is not a valid Montage relation operator") do
        @relation.parse_string_clause("foo <>< 'bar'")
      end
    end

    should "properly parse an = relation" do
      assert_equal({ foo: "bar" }, @relation.parse_string_clause("foo = 'bar'"))
    end

    should "properly parse a != relation" do
      assert_equal({ foo__not: "bar" }, @relation.parse_string_clause("foo != 'bar'"))
    end

    should "properly parse a > relation" do
      assert_equal({ foo__gt: "bar" }, @relation.parse_string_clause("foo > 'bar'"))
    end

    should "properly parse a >= relation" do
      assert_equal({ foo__gte: "bar" }, @relation.parse_string_clause("foo >= 'bar'"))
    end

    should "properly parse a < relation" do
      assert_equal({ foo__lt: "bar" }, @relation.parse_string_clause("foo < 'bar'"))
    end

    should "properly parse a <= relation" do
      assert_equal({ foo__lte: "bar" }, @relation.parse_string_clause("foo <= 'bar'"))
    end

    should "properly parse an IN relation" do
      assert_equal({ foo__in: "bar,barb,barber" }, @relation.parse_string_clause("foo IN (bar,barb,barber)"))
    end
    #
    # should "properly parse a CONTAINS relation" do
    #   assert_equal({ foo__contains: "bar" }, @relation.parse_string_clause("'bar' IN foo"))
    # end
  end

  context "#where" do
    setup do
      VCR.use_cassette("movies", allow_playback_repeats: true) do
        @relation = MontageRails::Relation.new(Movie)
      end
    end

    should "append the filter to the relation body" do
      expected = {
        filter: {
          foo__lte: 1.0
        }
      }

      assert_equal expected, @relation.where("foo <= 1").query
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
