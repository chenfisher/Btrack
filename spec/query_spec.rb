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

end