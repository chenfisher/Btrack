require 'spec_helper'
require 'btrack/helper'

describe Btrack::Helper do
  it "returns the right key" do
    Btrack::Helper.key("login", :daily, Time.now).should eq "btrack:login:#{Time.now.strftime('%Y-%m-%d')}"
  end

  it "accepts 'when' option" do
    Btrack::Helper.key("login", :daily, 1.days.ago).should eq "btrack:login:#{1.days.ago.strftime('%Y-%m-%d')}"
  end
end