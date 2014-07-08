module Btrack
  class Config

    # defaults
    @namespace = "btrack"
    @expirations = {minute: 1.day, hourly: 1.week, daily: 1.month, weekly: 3.months, monthly: 3.months, yearly: 1.year}

    class << self

      attr_accessor :namespace, :redis_url

      def expiration_for(g)
        @expirations[g]
      end

      def expiration_for=(g)
        @expirations.merge!(g)
      end

    end
  end
end