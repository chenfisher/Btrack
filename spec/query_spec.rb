require 'spec_helper'

describe Btrack::Query do

  xit "returns bitcount" do
    Btrack::Query.query("login", 123, :today).should be_true
  end

end