module Btrack
  class Helper

    class << self
      def key(k, g=Config.default_granularity, w=Time.now)
        "#{Config.namespace}:#{k}:#{granularity g, w || Time.now}"
      end

      def keys(k, timeframe)
        tf = timeframe.is_a?(TimeFrame) ? timeframe : (TimeFrame.new timeframe)
        tf.splat { |t| key k, tf.granularity, t}
      end

      def granularity(g=:daily, w=Time.now)
        return g unless [:minute, :hourly, :daily, :weekly, :monthly, :yearly].include? g
        w.strftime(format(g))
      end

      def format(g)
        { minute: "%Y-%m-%d-%H-%M", hourly: "%Y-%m-%d-%H", daily: "%Y-%m-%d", weekly: "%G-W%V", monthly: "%Y-%m", yearly: "%Y"}[g] || "%Y-%m-%d"
      end
    end

  end
end