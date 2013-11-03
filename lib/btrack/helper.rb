module Btrack
  class Helper

    class << self
      def key(k, g=:daily, w=Time.now)
        "#{Config.namespace}:#{k}:#{granularity g, w || Time.now}"
      end

      def granularity(g=:daily, w=Time.now)
        return g unless [:minute, :hourly, :daily, :weekly, :monthly, :yearly].include? g
        w.strftime(format(g))
      end

      def format(g)
        case g
        when :minute
          "%Y-%m-%d-%H-%M"
        when :hourly
          "%Y-%m-%d-%H"
        when :daily
          "%Y-%m-%d"
        when :weekly
          "%G-W%V"
        when :monthly
          "%Y-%m"
        when :yearly
          "%Y"
        else
          "%Y-%m-%d"
        end
      end
    end

  end
end