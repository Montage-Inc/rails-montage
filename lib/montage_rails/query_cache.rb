module MontageRails
  class QueryCache
    attr_accessor :cache
    
    def initialize
      @cache = {}
    end

    def get_or_set_query(query, klass)
      if cache.keys.include?("#{klass}/#{query}")
        cache["#{klass}/#{query}"]
      else
        response = yield
        cache["#{klass}/#{query}"] = response
        response
      end
    end
  end
end