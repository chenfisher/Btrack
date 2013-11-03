module Btrack
  class Config
    class << self

      attr_writer :namespace

      def namespace
        @namespace ||= "btrack"
      end

      def expiration_for(g)
        case g
        when :minute then 1.day
        when :hourly then 1.week
        when :daily then 1.month
        when :weekly then 3.month
        when :monthly then 3.month
        when :yearly then 1.years
        end
      end

    end
  end
end