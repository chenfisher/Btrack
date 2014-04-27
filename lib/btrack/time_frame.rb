module Btrack
  class TimeFrame
    attr_reader :from, :to, :granularity

    def initialize(timeframe, granularity=:daily)
      raise ArgumentError, "TimeFrame should be initialized with Symbol, Hash or Range" unless [Symbol, Hash, Range].include? timeframe.class
      @from, @to = self.send("init_with_#{timeframe.class.to_s.underscore}", timeframe)
      @granularity = granularity
    end

    def splat(granularity=self.granularity)
      [].tap do |keys|
        (from.to_i .. to.to_i).step(step(granularity)) do |t|
          keys << (block_given? ? (yield Time.at(t)) : Time.at(t))
        end
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
        when :this_week
          return Time.now.beginning_of_week, Time.now
        when :last_week
          return 1.week.ago.beginning_of_week..1.week.ago.end_of_week
        when :this_month
          return Time.now.beginning_of_month, Time.now
        when :last_month
          return 1.month.ago.beginning_of_month..1.month.ago.end_of_month
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
        case g
        when :minute then 1.minute
        when :hourly then 1.hour
        when :daily then 1.day
        when :weekly then 1.week
        when :monthly then 1.month
        when :yearly then 1.year
        else
          1.day
        end
      end
  end
end