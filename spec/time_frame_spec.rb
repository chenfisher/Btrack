require 'spec_helper'

describe Btrack::TimeFrame do
  it "defaults to Time.now and :daily" do
    expected = "#{Btrack.config.namespace}:login:#{Btrack::TimeFrame.granularity(:daily, Time.now)}"
    Btrack::TimeFrame.key("login").should eq expected
  end

  context "format" do
    it "returns the right key" do
      expected = "#{Btrack.config.namespace}:login:#{Btrack::TimeFrame.granularity(:weekly, Time.now)}"
      Btrack::TimeFrame.key("login", :weekly, Time.now).should eq expected
    end
  end
end