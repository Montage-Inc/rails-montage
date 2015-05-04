require 'test_helper'
require 'montage_rails/base'
require 'montage_rails/relation'
require 'will_paginate/collection'

class MontageRails::RelationTest < Minitest::Test
  context "#paginate" do
    setup do
      @movie = MontageRails::Relation.new(Movie).where(title: "The Jerk").limit(1)
    end

    should "return a will paginate collection if it is defined" do
      assert_equal "WillPaginate::Collection", @movie.paginate.class.name
    end

    should "return self if it is not defined" do
      Object.expects(:const_defined?).with("WillPaginate").returns(false)
      assert_equal @movie, @movie.paginate
    end
  end

  context "#reset" do
    setup do
      @movie = MontageRails::Relation.new(Movie).where(title: "The Jerk").limit(1)
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

      assert_nil @movie.cache.cache["Movie/{:filter=>{:title=>\"The Jerk\"}, :limit=>1}"]
      assert_equal "bar", @movie.cache.cache["foo/bar"]
    end
  end

  context "#reload" do
    setup do
      @movie = MontageRails::Relation.new(Movie).where(title: "The Jerk").limit(1)
    end

    should "reset the values and reload the relation" do
      @movie.reload

      assert !@movie.to_a.empty?
    end
  end

  context "#to_json" do
    setup do
      @relation = MontageRails::Relation.new(Movie)
    end

    should "parse the relation to a json format" do
      assert_equal "{\"filter\":{\"foo\":1.0,\"bar__gt\":2},\"order_by\":\"created_at\",\"ordering\":\"desc\",\"limit\":10}", @relation.where(foo: 1.0).where("bar > 2").order(created_at: :desc).limit(10).to_json
    end
  end

  context "#to_a" do
    should "return the record set without a query if the records have already been fetched" do
      @relation = MontageRails::Relation.new(Movie)

      @r = @relation.where("votes > 900000")
      @r.to_a

      assert @r.loaded?
    end

    should "query the remote db and return the record set if the records have not already been fetched" do
      @movies = MontageRails::Relation.new(Movie).where("votes > 900000").to_a

      assert_equal 1, @movies.count
    end
  end

  context "#inspect" do
    setup do
      @movie = MontageRails::Relation.new(Movie).where(title: "The Jerk").limit(1)
    end

    should "call to_a and inspect" do
      @movie.expects(:to_a).returns(stub(inspect: []))

      @movie.inspect
    end
  end
end
