module Btrack
  class Tracker
    class << self
      #
      # Tracks an event for a given user (or object)
      #
      # @param  *args [args] Can be a list of arguments, a Hash or a block
      #
      # When called with arguments, the following are expected:
      # @param [String] Event name to track
      # @param [Integer] User (or other entity you are tracking) id
      # @param [Symbol, Array, Range] The granularity to track the event; can a single granularity, an array of granularities or a range of granularities
      #     Possible granularities: [:minute, :hourly, :daily, :weekly, :monthly, :yearly]
      #
      # @example Different ways to pass granularities
      #   As a Symbol: :daily
      #   As an Array: [:daily, :monthly]
      #   As a Range: :hourly..:weekly
      #
      #   Btrack::Tracker.track "login", 123, :daily..:weekly
      #   @note Granularity range is inclusive
      #
      # @param [options] Options to be passed to the tracker
      # Possible options:
      #   @option when [Time] when (Time.now) If you want the tracker to consider this track at a specific time and not use Time.now
      #   @option expiration_for [type] expiration_for (See Btrack::Config for default expirations) sets the expiration (in seconds, in redis) for different granularities;
      #     for example, to set the expiration of the daily and weekly granularities: expiration_for:{daily:3.days, weekly:3.months}
      #
      # When called with a hash, the following are expected:
      # {event:[event name], id:[id of the object to track (like user)], granularity:[one of the mentioned granularities; can also be an array or range of granularities]}
      #
      # Optional keys in the hash are:
      # {when:[Time], expiration_for:[hash of granularities and their expiration in seconds]}
      #
      # @param  &block [block] If block is given then the block is used as the tracking parameters and options
      # @example Using a block
      #   Btrack::Tracker.track do |b|
      #     b.key = "login"
      #     b.id = 123
      #     b.granularity = :daily
      #     b.when = 3.days.ago
      #     b.expiration_for = { daily:6.days }
      #   end
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