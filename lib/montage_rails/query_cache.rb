module MontageRails
  class QueryCache
    attr_accessor :cache
    
    def initialize
      @cache = {}
    end

    def get_or_set_query(query, klass)
      cached = cache.keys.include?("#{klass}/#{query}")
      ActiveSupport::Notifications.instrument("reql.montage_rails", notification_payload(query, klass, cached: cached)) do
        if cached
          cache["#{klass}/#{query}"]
        else
          response = yield
          cache["#{klass}/#{query}"] = response
          response
        end
      end
    end

  private

    def notification_payload(query, klass, cached: false)
      {
        reql: query,
        name: "#{klass} Load#{' (Cache) ' if cached}"
      }
    end
  end
end