require 'btrack/query/criteria'
require 'btrack/query/lua'

module Btrack
  class Query
    attr_reader :criteria

    delegate :with_sha, :with_silent, to: Btrack::Redis

    class << self
      delegate :where, to: Criteria
    end

    def initialize(criteria = nil)
      @criteria = criteria.freeze
    end

    def count
      with_silent { with_sha { [lua(:count), *@criteria.realize!] } }
    end

    def exists?(id = nil)
      c = id ? @criteria.where([], id: id) : @criteria
      with_silent { with_sha { [lua(:exists), *c.realize!] }  == 1 }
    end

    def plot
      JSON.parse(with_silent { with_sha { [plot_lua, *@criteria.realize!] } }).inject({}) do |n, (k, v)|
        g = @criteria.criteria.first[:granularity] || Criteria.default_granularity
        key = Time.strptime(k.rpartition(":").last, Helper.format(g))
        n[key] = v
        n
      end.sort_by { |t, c| t }
    rescue
      nil
    end

    class << self
      def method_missing(method, *args, &block)
        return unless method.to_s.end_with? '?'
        Criteria.where({method.to_s.chomp('?') => args[1]}.merge(args.extract_options!), id: args[0]).exists?
      end
    end
  end
end