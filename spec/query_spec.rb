require 'spec_helper'

describe Btrack::Query do

  context "count" do
    before :each do
      10.times { |i| Btrack::Tracker.track "login", i, :hourly }
    end

    it "returns count" do
      Btrack::Query.count("login", :today, :hourly).should eq 10
    end

    it "accepts time frame" do
      10.times { |i| Btrack::Tracker.track "login", i+100, :hourly, when: 12.hours.ago }
      Btrack::Query.count("login", 1.days.ago..Time.now, :hourly).should eq 20
    end
  end

  context "query a user" do
    before :each do
      Btrack::Tracker.track "login", 123, :daily
    end

    it "returns true" do
      Btrack::Query.query("login", :today).should be_true
    end

    it "returns false" do
      Btrack::Query.query("login", :yesterday).should be_false
    end

    it "accepts timeframe" do
      Btrack::Query.query("login", 1.days.ago..Time.now).should be_true
    end
  end

end