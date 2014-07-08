require 'spec_helper'

describe Btrack::Config do

	Btrack.config do |config|
		config.namespace = "test"
	end

	it "sets a namespace" do
		assert { Btrack::Helper.key(:logged_in).starts_with? "test" }
	end

	it "sets expiration time" do
		expected = Btrack.config.expirations.dup
		Btrack.config.expiration_for = {weekly: 2.days}

		assert { Btrack.config.expirations == expected.merge(weekly: 2.days) }
	end
end