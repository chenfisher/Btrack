module Btrack
  class Query
    class Criteria
      attr_reader :options

      def initialize(options={})
        @options = options
      end

      def method_missing(method, *args, &block)
        if !@options[:key] && method.to_s.end_with?("?")
          set_key_and_timeframe(method, args.first) && self
        elsif !@options[:id]
          set_id(args.first) && self
        else
          super
        end
      end

      class << self
        def method_missing(method, *args, &block)
          Criteria.new.send(method, *args, &block)
        end
      end

      private

        def set_id(id)
          @options[:id] = id
        end

        def set_key_and_timeframe(key, timeframe)
          @options[:key] = key.to_s.chomp '?'
          @options[:timeframe] = timeframe
        end
    end
  end
end