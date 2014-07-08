require 'spec_helper'

describe Btrack::Config do

	Btrack.config do |config|
		config.namespace = "test"
	end

	it "sets a namespace" do
		assert { Btrack::Helper.key(:logged_in).starts_with? "test" }
	end

	it "sets a redis url" do
		Btrack.config.redis_url = "http://some-bogus-redis-url.com"
		assert { Btrack.redis.client.host == "http://some-bogus-redis-url.com" }
	end
end