require 'spec_helper'
require 'btrack/helper'

describe Btrack::Tracker do

  it "calls track_with_hash with expected hash" do
    expected = { key: "login", granularity: :daily, id: 123 }
    Btrack::Tracker.should_receive(:track_with_hash).with expected

    Btrack::Tracker.track "login", 123, :daily
  end

  it "block calls track_with_hash with expected hash" do
    expected = OpenStruct.new(key: "login", granularity: :daily, id: 123)
    Btrack::Tracker.should_receive(:track_with_hash).with expected

    Btrack::Tracker.track do |b|
      b.key = "login"
      b.id = 123
      b.granularity = :daily
    end
  end

  it "tracks the metric" do
    Btrack::Tracker.track "login", 123, :daily
    Btrack.redis.getbit(Btrack::Helper.key("login", :daily, Time.now), 123).should eq 1
  end

  it "defaults to daily granularity" do
    Btrack::Tracker.track "login", 123
    Btrack.redis.getbit(Btrack::Helper.key("login", :daily, Time.now), 123).should eq 1
  end

  it "tracks granularity range" do
    Btrack::Tracker.track "login", 123, :daily..:monthly

    Btrack.redis.getbit(Btrack::Helper.key("login", :daily, Time.now), 123).should eq 1
    Btrack.redis.getbit(Btrack::Helper.key("login", :weekly, Time.now), 123).should eq 1
    Btrack.redis.getbit(Btrack::Helper.key("login", :monthly, Time.now), 123).should eq 1
  end

  it "accepts granularity array" do
    Btrack::Tracker.track "login", 123, [:daily, :monthly]

    Btrack.redis.getbit(Btrack::Helper.key("login", :daily, Time.now), 123).should eq 1
    Btrack.redis.getbit(Btrack::Helper.key("login", :weekly, Time.now), 123).should eq 0
    Btrack.redis.getbit(Btrack::Helper.key("login", :monthly, Time.now), 123).should eq 1
  end

  it "accepts 'when' parameter" do
    Btrack::Tracker.track "login", 123, :daily, when: 3.days.ago
    Btrack.redis.getbit(Btrack::Helper.key("login", :daily, Time.now), 123).should eq 0
    Btrack.redis.getbit(Btrack::Helper.key("login", :daily, 3.days.ago), 123).should eq 1
  end

  it "sets expiration for keys" do
    Btrack::Tracker.track "login", 123, :daily
    Btrack.redis.ttl(Btrack::Helper.key("login", :daily, Time.now)).should eq Btrack::Config.expiration_for :daily
  end

  it "overrides expiration set in config" do
    Btrack::Tracker.track "login", 123, :weekly, expiration_for:{weekly:3.months}
    Btrack.redis.ttl(Btrack::Helper.key("login", :weekly, Time.now)).should eq 3.months
  end
end