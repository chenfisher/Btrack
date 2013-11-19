require 'hook_me_up'

module Btrack
  module Trackable
    module ClassMethods
      def track(*args)
        options = args.extract_options!
        op = options.dup
        op[:key] = op[:key] || args.first # use the event name specified (key) or the method name if no key was specified

        hook_me_up args.first, after: lambda{ |sender, *args|
          op[:id] = op[:id].call(*args) if op[:id].is_a? Proc
          Btrack::Tracker.track op
        }
      end
    end

    module InstanceMethods

    end

    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
      receiver.send :include, HookMeUp
    end
  end
end