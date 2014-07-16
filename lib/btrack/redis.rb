require 'redis'
require 'btrack/config'

module Btrack
  class Redis
    class << self
      def create
        (::Redis.new url: Config.redis_url if Config.redis_url) || ::Redis.new
      end

	    def with_silent(&block)
	      yield if block
	    rescue ::Redis::BaseError => e
	      raise e unless Config.silent
	    end

	    def with_sha(&block)
	    	params = yield; script = params.shift
	    	Btrack.redis.evalsha sha(script), *params
	    rescue ::Redis::CommandError => e
	      raise unless e.message.start_with?("NOSCRIPT")
	      Btrack.redis.eval script, *params
	    end

	    def sha(script)
	    	Digest::SHA1.hexdigest(script)
	    end
    end
  end
end