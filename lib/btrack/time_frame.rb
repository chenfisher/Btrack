module Btrack
  class TimeFrame
    attr_reader :from, :to, :granularity

    def initialize(timeframe, granularity=nil)
      raise ArgumentError, "TimeFrame should be initialized with Symbol, Hash, Range or Btrack::TimeFrame" unless [Symbol, Hash, Range, TimeFrame, Time].include? timeframe.class

      @from, @to = self.send("init_with_#{timeframe.class.name.demodulize.underscore}", timeframe)
      @granularity = granularity || (timeframe.granularity if timeframe.is_a?(TimeFrame)) || Config.default_granularity
    end

    def splat(granularity=self.granularity)
      [].tap do |keys|
        (from.to_i .. to.to_i).step(step(granularity)) do |t|
          keys << (block_given? ? (yield Time.at(t)) : Time.at(t))
        end
      end
    end

    private
      def init_with_time_frame(timeframe)
        [timeframe.from, timeframe.to]
      end

      def init_with_time(time)
        [time.beginning_of_day, time.end_of_day]
      end

      def init_with_symbol(timeframe)
        case timeframe
        when :hour, :day, :week, :month, :year
          return 1.send(timeframe).ago, Time.now
        when :today
          return Time.now.beginning_of_day, Time.now
        when :yesterday
          return 1.day.ago.beginning_of_day, 1.day.ago.end_of_day
        when :this_week
          return Time.now.beginning_of_week, Time.now
        when :last_week
          return 1.week.ago.beginning_of_week, 1.week.ago.end_of_week
        when :this_month
          return Time.now.beginning_of_month, Time.now
        when :last_month
          return 1.month.ago.beginning_of_month, 1.month.ago.end_of_month
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

      def step(g)
        {minute: 1.minute, hourly: 1.hour, daily: 1.day, weekly: 1.week, monthly: 1.month, yearly: 1.year}[g] || 1.day
      end
  end
end