module Btrack
  class Config
    class << self

      attr_writer :namespace

      def namespace
        @namespace ||= "btrack"
      end

      def expiration_for(g)
        {minute: 1.day, hourly: 1.week, daily: 1.month, weekly: 3.months, monthly: 3.months, yearly: 1.year}[g] || 1.week
      end

    end
  end
end