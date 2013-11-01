require 'spec_helper'
require 'btrack/helper'

describe Btrack::Tracker do

  before :each do
    Btrack.config do |config|
      Btrack.redis.flushdb
      Btrack.redis.select 15
    end
  end

  it "calls track_with_hash with expected hash" do
    expected = { key: "login", granularity: :daily, id: 123 }
    Btrack::Tracker.should_receive(:track_with_hash).with expected

    Btrack::Tracker.track "login", 123, :daily
  end

  it "tracks the metric" do
    Btrack::Tracker.track "login", 123, :daily
    Btrack.redis.getbit(Btrack::Helper.key("login", :daily, Time.now), 123).should eq 1
  end

  # it "accepts a block" do
  #   Btrack.track do |b|
  #     b.key = "login"
  #     b.user_id = 123
  #     b.granularity = :daily
  #   end
  # end

  # it "accepts a hash" do
  #   Btrack.track key: "login", user_id: 123, granularity: :daily
  # end

  # it "defaults to daily granularity"
  # it "accepts granularity range"
  # it "accepts granularity array"
  # it "accepts 'when' parameter"

  # it "sets expiration for keys"
end