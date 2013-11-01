require 'spec_helper'
require 'btrack/helper'

describe Btrack::Helper do
  it "returns the right key" do
    Btrack::Helper.key("login", :daily, Time.now).should eq "btrack:login:#{Btrack::Helper.granularity(:daily, Time.now)}"
  end
end