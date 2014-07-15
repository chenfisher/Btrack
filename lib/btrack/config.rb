module Btrack
  class Config

    @config = OpenStruct.new ({
          namespace: "btrack",
          redis_url: nil, # nil means localhost with defailt redis port
          expirations: {minute: 1.day, hourly: 1.week, daily: 1.month, weekly: 3.months, monthly: 3.months, yearly: 1.year},
          default_granularity: :daily
        })

    class << self

      def expiration_for(g)
        @config[:expirations][g]
      end

      def expiration_for=(g)
        @config[:expirations].merge!(g)
      end

      def method_missing(method, *args, &block)
        @config.send(method, *args, &block)
      end

    end
  end
end