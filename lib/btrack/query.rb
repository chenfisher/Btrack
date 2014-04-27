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
  end
end