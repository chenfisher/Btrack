require 'redis'
require 'btrack/config'

module Btrack
  class Redis
    class << self
      def create
        (::Redis.new Config.redis_url if Config.redis_url) || ::Redis.new
      end
    end
  end
end