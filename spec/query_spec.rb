require 'spec_helper'

describe Btrack::Query do

	before :each do
	  10.times do |i|
	    Btrack.track :logged_in, i, :hourly..:monthly # [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
	    Btrack.track :logged_in, i*2, when: 1.days.ago # [0, 2, 4, 6, 8, 10, 12, 14, 16, 18]

	    Btrack.track :visited, i if i%3 == 0 # [0, 3, 6, 9]
	  end
	end


  it "returns count of unique logins for today" do
    assert { Btrack.where(logged_in: :today).count == 10 }
  end

  it "returns count of unique logins yesterday" do
    assert { Btrack.where(logged_in: :yesterday).count == 10 }
  end

  it "returns count of unique logins in a range of time" do
    assert { Btrack.where(logged_in: 1.days.ago..Time.now).count == 15 }
  end

  it "returns count with weekly granularity" do
  	assert { Btrack.where([{logged_in: :this_week, granularity: :weekly}]).count == 15 }
	end

	it "returns the intersection of two different time frames" do
  	assert { Btrack.where([{logged_in: :today}, {logged_in: :yesterday}]).count == 5 }
	end

	it "returns the intersection of two different activities" do
  	assert { Btrack.where([{logged_in: :yesterday}, {visited: :today}]).count == 2 }
	end

  it "check if id exists in activity" do
    assert { Btrack.where(logged_in: :today).exists? 5 }
  end

  it "checks if id did two activities (intersection)" do
  	assert { Btrack.where([{logged_in: :yesterday}, {visited: :today}], id: 6).exists? }
  end

  it "should return false for id that does not satisfies an intersection" do
  	assert { Btrack.where([{logged_in: :yesterday}, {visited: :today}], id: 3).exists? == false }
  end

end