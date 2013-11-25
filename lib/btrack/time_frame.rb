module Btrack
  class TimeFrame
    attr_reader :from, :to

    def initialize(timeframe)
      raise ArgumentError, "TimeFrame should be initialized with Symbol, Hash or Range" unless [Symbol, Hash, Range].include? timeframe.class
      @from, @to = self.send("init_with_#{timeframe.class.to_s.underscore}", timeframe)
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
        [timeframe[:from] && timeframe[:from].is_a?(String) && Time.parse(timeframe[:from]) || timeframe[:from] || 1.month.ago,
        timeframe[:to] && timeframe[:to].is_a?(String) && Time.parse(timeframe[:to]) || timeframe[:to] || Time.now]
      end

      def init_with_range(timeframe)
        init_with_hash(from: timeframe.first, to: timeframe.last)
      end
  end
end