require 'btrack/query/criteria'

module Btrack
  class Query
    attr_reader :criteria

    class << self
      delegate :where, to: Criteria
    end

    def initialize(criteria = nil)
      @criteria = criteria
    end

    def count
      Btrack.redis.eval(lua(:count), *@criteria.realize!)
    end

    def exists
      keys, args = @criteria.realize!
      Btrack.redis.eval(lua(:exists), *@criteria.realize!)
    end

    def plot
      JSON.parse Btrack.redis.eval(plot_lua, *@criteria.realize!)
    end

    private
      def lua(f)
        %Q{
          local index = 1

          for i, count in ipairs(ARGV) do
            if count == '0' then
              break
            end

            local bitop = {}

            for c = index, index * count do
              table.insert(bitop, KEYS[c])
              index = index + 1
            end

            if i == 1 then
              redis.call('bitop', 'or', 'tmp', unpack(bitop))
            else
              redis.call('bitop', 'or', 'tmp:or', unpack(bitop))
              redis.call('bitop', 'and', 'tmp', 'tmp', 'tmp:or')
              redis.call('del', 'tmp:or')
            end
          end

          #{send('lua_' + f.to_s)}

          redis.call('del', 'tmp')
          return results
        }          
      end

      def lua_count
        "local results = redis.call('bitcount', 'tmp')"
      end

      def lua_exists
        "local results = redis.call('getbit', 'tmp', KEYS[#KEYS])"
      end

      # lua script for plotting
      # please note - it cannot be used with the prefixed 'lua' like count and exists
      # this is a standalone script ment for plotting and allowing for cohort analysis
      # all series must be of the same size
      def plot_lua
        %Q{
          local series_count = #ARGV
          local length = ARGV[1]

          -- run over the first series
          -- all series must be of the same size
          local plot = {}
          for i = 1, length do
            local bitop = {}
            for j = 1, series_count do
              table.insert(bitop, KEYS[i*j])
            end

            -- make sure 'tmp' is populated with the first key (so the 'and' op would work as expected)
            redis.call('bitop', 'or', 'tmp', 'tmp', bitop[1])

            redis.call('bitop', 'and', 'tmp', unpack(bitop))
            -- table.insert(plot, redis.call('bitcount', 'tmp'))
            plot[KEYS[i]] = redis.call('bitcount', 'tmp')
            redis.call('del', 'tmp')
          end

          return cjson.encode(plot)
        }          
      end
  end
end