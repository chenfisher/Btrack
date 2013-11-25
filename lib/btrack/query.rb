module Btrack
  class Query
    class << self

      def count(key, timeframe)
        tf = TimeFrame.new timeframe

        keys = []
        (tf.from.to_i ... tf.to.to_i).step(step(granularity)) do |t|
          t = TimeFrame.key(granularity, Time.at(t))
          keys << "#{config.namespace}:#{key}:#{t}"
        end

        results = [].tap do |r|
          Redis.current.eval(lua, keys).each_slice(2) do |key, value|
            r << {time:parse_time(key, granularity), count:value}
          end
        end
      end

      private
        def step(g)
          case g
          when :minute then 1.minute
          when :hourly then 1.hour
          when :daily then 1.day
          when :weekly then 1.week
          when :monthly then 1.month
          when :yearly then 1.year
          else
            1.day
          end
        end


    end
  end
end