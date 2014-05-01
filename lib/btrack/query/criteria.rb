require 'btrack/helper'
require 'btrack/time_frame'

module Btrack
  class Query
    class Criteria
      attr_reader :options
      delegate :count, :exists?, :plot, to: :query

      # initializes a new crieteria
      # args must contain an array (or hash) of criteria and and optional options
      # examples: 
      # Criteria.new [name: "chen", sur: "fisher"], prefix: "item"
      # Criteria.new {name: "chen", sur: "fisher"}, prefix: "item"
      # Criteria.new name: "chen", sur: "fisher"
      def initialize(*args)
        options = args.pop if args.last.is_a?(Hash) && args.size > 1
        @options = (options ||= {}).merge(criteria: (parse args).flatten)
      end

      # returns a new criteria object with the union of both criterias
      def where(criteria)
        Criteria.new @options[:criteria] + parse(criteria), @options
      end

      # make this criteria 'real' by extracting keys and args to be passed to redis lua script
      def realize!
        prefix = "#{@options[:prefix]}:" if @options[:prefix]

        keys = @options[:criteria].map do |c|
          (Helper.keys "#{prefix}#{c.keys.first}", TimeFrame.new(c.values.first, c[:granularity] || :daily)).flatten
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

      private

        # criteria is expected to be an array or a hash
        # transform criteria to an array of hashes
        def parse(criteria)
          criteria.is_a?(Array) ? criteria : criteria.map { |k, v| {k => v} }
        end
    end
  end
end