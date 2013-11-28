require 'spec_helper'

describe Btrack::Query::Criteria do
  before :each do
    10.times { |i| Btrack::Tracker.track "logged_in", i, :hourly..:monthly }
  end

  it "returns a Criteria with expected options" do
    expected = {key: "logged_in", id: 123, timeframe: :today}
    Btrack::Query::Criteria.user(123).logged_in?(:today).options.should eq expected
  end
end