require 'spec_helper'
require 'btrack/helper'

describe Btrack::Tracker do

  it "tracks with basic args" do
    Btrack::Tracker.track("logged_in", 123, :weekly)
    assert { is_set "logged_in", 123, :weekly }
  end

  it "tracks with default granularity" do
    Btrack::Tracker.track("logged_in", 123)
    assert { is_set "logged_in", 123 }
  end

  it "accepts symbol as key" do
    Btrack::Tracker.track(:logged_in, 123)
    assert { is_set :logged_in, 123 }
  end

  it "accepts different time (past activity)" do
    Btrack::Tracker.track(:logged_in, 123, :daily, when: 3.days.ago)
    assert { is_set :logged_in, 123, :daily, 3.days.ago }
  end

  it "track with expiration time set" do
    Btrack::Tracker.track(:logged_in, 123, :daily, expiration_for: { daily: 9.days })
    assert { ttl(:logged_in, 123, :daily) == 9.days }
  end

  it "tracks with a block" do
    Btrack::Tracker.track do |t|
      t.key = :logged_in
      t.id = 123
      t.granularity = :weekly
      t.when = 2.days.ago
    end

    assert { is_set :logged_in, 123, :weekly, 2.days.ago }
  end

end