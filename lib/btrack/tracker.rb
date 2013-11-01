module Btrack
  class Tracker
    class << self
      def track(*args, &block)
        return track_with_block(&block) if block_given?
        return track_with_hash if args.first === Hash

        track_with_args(*args)
      end

      private

        def track_with_hash(options)
          key = Helper.key options[:key], options[:granularity], options[:when]
          Btrack.redis.setbit key, options[:id].to_i, 1
        end

        def track_with_block
          yield
        end

        def track_with_args(*args)
          options = {
            key: args[0],
            id: args[1],
            granularity: args[2],
          }

          track_with_hash options
        end
    end
  end
end