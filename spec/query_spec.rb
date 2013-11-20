require 'spec_helper'

describe Btrack::Query do

  context "count" do
    10.times { |i| Btrack::Tracker.track "login", i, :daily }

    it "returns count" do
      Btrack::Query.count("login", :today).should eq 10
    end

    it "accepts time frame"
  end

end