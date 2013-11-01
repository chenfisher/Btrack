require 'redis'

module Btrack
  class Redis
    class << self
      def create(url = nil)
        (::Redis.new url if url) || ::Redis.new
      end
    end
  end
end