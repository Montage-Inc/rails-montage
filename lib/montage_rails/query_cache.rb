module MontageRails
  class QueryCache
    attr_reader :cache
    attr_accessor :no_cache

    def initialize(no_cache = false)
      @cache = {}
      @no_cache = no_cache
    end

    def get_or_set_query(klass, query)
      cached = cache.keys.include?("#{klass}/#{query}") && !no_cache
      ActiveSupport::Notifications.instrument("reql.montage_rails", notification_payload(query, klass, cached)) do
        if cached
          cache["#{klass}/#{query}"]
        else
          response = yield
          cache["#{klass}/#{query}"] = response
          response
        end
      end
    end

    # Clear the entire query cache
    #
    def clear
      @cache = {}
    end

    # Remove a certain key from the cache
    # Returns the removed value, or nil if nothin was found
    #
    def remove(key)
      cache.delete(key)
    end

  private

    def notification_payload(query, klass, cached = false)
      {
        reql: query,
        name: cached ? "#{klass} Load [CACHE]" : "#{klass} Load"
      }
    end
  end
end
