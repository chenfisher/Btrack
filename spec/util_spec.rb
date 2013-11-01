require 'spec_helper'

describe Btrack::Util do
  context "granularity" do
    it "should return expected format" do
      Btrack::Util.granularity(:hourly, ).should eq ""
    end
  end
end