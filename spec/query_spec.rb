require 'spec_helper'

describe Btrack::Query do

  it "returns bitcount" do
    Btrack::Query.query("login", 123, :today).should be_true
  end

end