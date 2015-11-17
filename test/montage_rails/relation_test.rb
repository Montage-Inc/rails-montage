require 'test_helper'
require 'montage_rails/base'
require 'montage_rails/relation'

class MontageRails::RelationTest < Minitest::Test
  context "#paginate" do
    setup do
      @movie = MontageRails::Relation.new(Movie).where(title: "The Jerk").limit(1)
    end

    context "when will paginate is defined" do
      setup do
        require 'will_paginate/collection'
        Object.send(:remove_const, :Kaminari) if Object.const_defined?("Kaminari")
      end

      should "return a will paginate collection" do
        assert_equal "WillPaginate::Collection", @movie.paginate.class.name
      end
    end

    context "when kaminari is defined" do
      setup do
        require 'kaminari'
        Kaminari::Hooks.init
        Object.send(:remove_const, :WillPaginate) if Object.const_defined?("WillPaginate")
      end

      should "return a Kaminari collection" do
        assert_equal "Kaminari::PaginatableArray", @movie.paginate.class.name
      end
    end

    context "when no paginator is defined" do
      should "return self" do
        assert_equal @movie.first.attributes, @movie.paginate.first.attributes
      end
    end
  end

  context "#exists?" do
    should "return false if the record does not exist" do
      refute MontageRails::Relation.new(Movie).where(title: "Foo").exists?
    end

    should "return true if the record does exist" do
      assert MontageRails::Relation.new(Movie).where(title: "The Jerk").exists?
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

  context "#pluck" do
    should "return an array of plucked values" do
      assert_equal ["The Jerk"], MontageRails::Relation.new(Movie).where(title: "The Jerk").pluck(:title)
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

  context "#loadable?" do
    setup do
      @relation = MontageRails::Relation.new(Movie)
    end

    should "be loadable in the test enviroment" do
      Rails.stubs(:env).returns("test")
      assert @relation.loadable?
    end

    should "be loadable in the development environment" do
      Rails.stubs(:env).returns("development")
      assert @relation.loadable?
    end

    should "be loadable in the production env when not loaded" do
      Rails.stubs(:env).returns("production")
      @relation.stubs(:loaded?).returns(false)
      assert @relation.loadable?
    end

    should "not be loadable in the production env when loaded" do
      Rails.stubs(:env).returns("production")
      @relation.stubs(:loaded?).returns(true)
      refute @relation.loadable?
    end

    should "be loadable in the test env when loaded" do
      Rails.stubs(:env).returns("test")
      @relation.stubs(:loaded?).returns(true)
      assert @relation.loadable?
    end

    should "be loadable in the dev env when loaded" do
      Rails.stubs(:env).returns("development")
      @relation.stubs(:loaded?).returns(true)
      assert @relation.loadable?
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
      @movies = MontageRails::Relation.new(Movie).where("votes > 5").to_a

      assert_equal 2, @movies.count
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
