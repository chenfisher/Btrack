require 'btrack/helper'
require 'btrack/time_frame'

module Btrack
  class Query
    class Criteria
      attr_reader :options, :criteria
      delegate :count, :exists?, :plot, to: :query

      # initializes a new crieteria
      def initialize(criteria, options={})
        @criteria = Array.wrap(criteria)
        @options = options
      end

      # returns a new criteria object with the union of both criterias
      def where(*args)
        self & Criteria.new(*args)
      end

      # returns a new criteria object with the union of both criterias
      def &(criteria)
        Criteria.new self.criteria + criteria.criteria, self.options.merge(criteria.options)
      end

      # make this criteria 'real' by extracting keys and args to be passed to redis lua script
      def realize!
        prefix = "#{@options[:prefix]}:" if @options[:prefix]

        keys = @criteria.map do |c|
          cvalue = c.values.first
          (Helper.keys "#{prefix}#{c.keys.first}", TimeFrame.new(cvalue, c[:granularity] || (cvalue.granularity if cvalue.is_a? TimeFrame) || Array.wrap(Config.default_granularity).last)).flatten
        end

        [keys.flatten << @options[:id], keys.map(&:count)]
      end

      # access methods from class instance
      # returns a new criteria instance
      class << self
        def where(*args)
          Criteria.new *args
        end
      end

      # delegate method
      def query
        Query.new self
      end
    end
  end
end