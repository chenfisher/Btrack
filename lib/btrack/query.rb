require 'btrack/query/criteria'

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

      def query(key, timeframe, granularity=:daily)
        tf = TimeFrame.new timeframe

        keys = []
        (tf.from.to_i .. tf.to.to_i).step(step(granularity)) do |t|
          keys << Btrack::Helper.key(key, granularity, Time.at(t))
        end

        !!Btrack.redis.eval(lua_exists, keys)
      end

      def method_missing(method, *args, &block)
        Criteria.new.send(method, *args, &block)
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
            redis.call('bitop', 'or', 'tmp', unpack(KEYS))
            local count = redis.call('bitcount', 'tmp')

            redis.call('del', 'tmp')
            return count
          }
        end

        def lua_exists
          %Q{
            for i, k in ipairs(KEYS) do
              if redis.call('bitcount', k) > 0 then
                return true
              end
            end

            return false
          }
        end
    end
  end
end