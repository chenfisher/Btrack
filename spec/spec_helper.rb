require 'rubygems'
require 'bundler/setup'

require 'btrack'

RSpec.configure do |config|
  config.before :each do
    Btrack.redis.select 15
    Btrack.redis.flushdb
  end
end
