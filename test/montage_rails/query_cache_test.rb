require 'test_helper'
require 'montage_rails/query_cache'

class QueryCacheTest < Minitest::Test
  context "#get_or_set_query" do
    setup do
      @meth = Struct.new(:foo)
      @cache = MontageRails::QueryCache.new
    end

    context "when the query is already cached" do
      setup do
        @cache.cache["foo/bar"] = "foobar"
      end

      should "not run the query, and return the cached value" do
        @meth.expects(:foo).never
        @cache.get_or_set_query("foo", "bar") do
          @meth.foo
        end
      end
    end

    context "when the query is not already cached, and set the cached value" do
      should "run the query" do
        @meth.expects(:foo).once.returns("bar")
        @cache.get_or_set_query("foo", "bar") do
          @meth.foo
        end

        assert_equal @cache.cache["foo/bar"], "bar"
      end
    end
  end

  context "#clear" do
    setup do
      @meth = Struct.new(:foo)
      @cache = MontageRails::QueryCache.new
    end

    should "clear the cache" do
      @meth.stubs(:foo).once.returns("bar")
      @cache.get_or_set_query("foo", "bar") { @meth.foo }
      @cache.clear

      assert @cache.cache.empty?
    end
  end
end
