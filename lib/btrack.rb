require 'active_support/all'
require "btrack/version"
require "btrack/helper"
require "btrack/config"
require "btrack/time_frame"
require "btrack/redis"
require "btrack/tracker"
require "btrack/query"

module Btrack
  extend self

  delegate :where, to: Query
  delegate :track, to: Tracker 

  def redis
    @redis ||= Btrack::Redis.create
  end

  def config
    yield Btrack::Config if block_given?
    Btrack::Config
  end
end
