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
      keys, args = @criteria.realize!
      Btrack.redis.eval(lua_count, keys.flatten, args)
    end

    private
      def prefix
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

          local count = redis.call('bitcount', 'tmp')
          redis.call('del', 'tmp')
          return count
        }          
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
          redis.call('bitop', 'or', 'tmp', unpack(KEYS))
          local exists = redis.call('getbit', 'tmp', ARGV[1])

          redis.call('del', 'tmp')
          return exists
        }
      end
  end
end