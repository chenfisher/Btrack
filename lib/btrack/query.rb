module Btrack
  class Query
    class << self

      def count(key, timeframe)
        tf = TimeFrame.new timeframe
      end

    end
  end
end