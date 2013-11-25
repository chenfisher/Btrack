module Btrack
  class Query
    class << self

      def count(key, timeframe, granularity=:daily)
        tf = TimeFrame.new timeframe

        keys = []
        (tf.from.to_i .. tf.to.to_i).step(step(granularity)) do |t|
          keys << Btrack::Helper.key(key, granularity, Time.at(t))
        end

        Btrack.redis.eval(lua_count, keys)
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

        def lua_count
          %Q{
            local tmp = "tmp"
            local count = 0
            for i, k in ipairs(KEYS) do
              count = count + redis.call('bitcount', k)
            end

            return count
          }
        end
    end
  end
end