require 'spec_helper'
require 'btrack/helper'

class Dummy
  include Btrack::Trackable

  def dummy(user_id)
    puts user_id
  end
  track :dummy, id: lambda{ |*args| args.first }, granularity: :daily, when: 3.days.ago, expiration_for:{daily: 1.minute}
end

describe Btrack::Trackable do
  let(:dummy) { Dummy.new }

  it "tracks a model's method" do
    dummy.dummy(999)
    Btrack.redis.getbit(Btrack::Helper.key("dummy", :daily, 3.days.ago), 999).should eq 1
    Btrack.redis.ttl(Btrack::Helper.key("dummy", :daily, 3.days.ago)).should eq 1.minute
  end
end