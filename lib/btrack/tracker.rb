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
          granularity_range(options[:granularity] || :daily).each do |g|
            key = Helper.key options[:key], g, options[:when]

            Btrack.redis.pipelined do |r|
              r.setbit key, options[:id].to_i, 1
              r.expire key, options[:expiration_for] && options[:expiration_for][g] || Config.expiration_for(g)
            end
          end
        end

        def track_with_block
          yield options = OpenStruct.new

          track_with_hash options
        end

        def track_with_args(*args)
          options = {
            key: args[0],
            id: args[1],
            granularity: args[2]
          }

          track_with_hash options.merge(args.extract_options!)
        end

        def granularity_range(granularities)
          return [granularities].flatten unless granularities.is_a? Range
          predefined[predefined.index(granularities.first)..predefined.index(granularities.last)]
        end

        def predefined; [:minute, :hourly, :daily, :weekly, :monthly, :yearly]; end
    end
  end
end