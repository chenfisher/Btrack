require 'spec_helper'

describe Btrack::TimeFrame do
  it "accepts time as from and to" do
    tf = Btrack::TimeFrame.new from: 10.days.ago, to: Time.now
    tf.from.to_i.should eq 10.days.ago.to_i
    tf.to.to_i.should eq Time.now.to_i
  end
end