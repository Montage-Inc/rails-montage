module MontageRails
  class LogSubscriber < ActiveSupport::LogSubscriber
    def self.runtime=(value)
      Thread.current["montage_rails_reql_runtime"] = value
    end

    def self.runtime
      Thread.current["montage_rails_reql_runtime"] ||= 0
    end

    def self.reset_runtime
      rt, self.runtime = runtime, 0
      rt
    end

    def initialize
      super
      @odd_or_even = false
    end

    def reql(event)
      self.class.runtime += event.duration
      return unless logger.debug?

      name = '%s (%.1fms)' % [event.payload[:name], event.duration]
      reql  = event.payload[:reql]

      if odd?
        name = color(name, CYAN, true)
        reql  = color(reql, nil, true)
      else
        name = color(name, MAGENTA, true)
      end

      if event.payload[:cached]
        name = "#{name}[CACHE]"
      end

      debug "  #{name}  #{reql}"
    end

    def odd?
      @odd_or_even = !@odd_or_even
    end

    def logger
      MontageRails::Base.logger
    end
  end
end

MontageRails::LogSubscriber.attach_to :montage_rails