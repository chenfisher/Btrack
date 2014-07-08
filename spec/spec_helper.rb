require 'rubygems'
require 'bundler/setup'
require "wrong/adapters/rspec"
require 'btrack'

RSpec.configure do |config|
  config.before :each do
    Btrack.redis.select 15
    Btrack.redis.flushdb
  end
end

def is_set(key, id, granularity = :daily, w = Time.now)
	Btrack.redis.getbit(Btrack::Helper.key(key, granularity, w), id) == 1
end

def ttl(key, id, granularity = :daily, w = Time.now)
	Btrack.redis.ttl(Btrack::Helper.key(key, granularity, w))
end