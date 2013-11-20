module Btrack
  class TimeFrame
    attr_reader :from, :to

    def initialize(timeframe)
      @timeframe = timeframe

      @from, @to = case timeframe
      when Symbol
        init_with_symbol(timeframe)
      when Hash
        init_with_hash(timeframe)
      end
    end

    private
      def init_with_symbol(timeframe)
        case timeframe
        when :hour, :day, :week, :month, :year
          return 1.send(timeframe).ago, Time.now
        when :today
          return Time.now.beginning_of_day, Time.now
        when :yesterday
          return 1.day.ago.beginning_of_day, 1.day.ago.end_of_day
        else
          return 1.day.ago, Time.now
        end
      end

      def init_with_hash(timeframe)
        from = timeframe[:from] && timeframe[:from].is_a?(String) && Time.parse(timeframe[:from]) || timeframe[:from] || 1.month.ago
        to = timeframe[:to] && timeframe[:to].is_a?(String) && Time.parse(timeframe[:to]) || timeframe[:to] || Time.now

        return from, to
      end
  end
end