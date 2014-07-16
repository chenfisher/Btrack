require 'btrack/query/criteria'
require 'btrack/query/lua'

module Btrack
  class Query
    attr_reader :criteria

    class << self
      delegate :where, to: Criteria
    end

    def initialize(criteria = nil)
      @criteria = criteria.freeze
    end

    def count
      Btrack::Redis.with_sha { [lua(:count), *@criteria.realize!] }
    end

    def exists?(id = nil)
      c = id ? @criteria.where([], id: id) : @criteria
      Btrack::Redis.with_sha { [lua(:exists), *c.realize!] }  == 1
    end

    def plot
      JSON.parse Btrack::Redis.with_sha { [plot_lua, *@criteria.realize!] }
    end

    class << self
      def method_missing(method, *args, &block)
        return unless method.to_s.end_with? '?'
        Criteria.where({method.to_s.chomp('?') => args[1]}.merge(args.extract_options!), id: args[0]).exists?
      end
    end
  end
end