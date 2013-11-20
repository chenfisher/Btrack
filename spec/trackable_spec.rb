require 'spec_helper'
require 'btrack/helper'

class Dummy
  include Btrack::Trackable

  def dummy(user_id)
    puts user_id
  end
  track :dummy, key: "logged_in", id: lambda{ |*args| args.first }, granularity: :daily, when: 3.days.ago, expiration_for:{daily: 1.minute}

  def no_key(user_id)
    puts user_id
  end
  track :no_key, id: lambda{ |*args| args.first }, granularity: :daily, when: 3.days.ago, expiration_for:{daily: 1.minute}
end

describe Btrack::Trackable do
  let(:dummy) { Dummy.new }

  it "tracks a model's method" do
    dummy.dummy(999)
    Btrack.redis.getbit(Btrack::Helper.key("logged_in", :daily, 3.days.ago), 999).should eq 1
    Btrack.redis.ttl(Btrack::Helper.key("logged_in", :daily, 3.days.ago)).should eq 1.minute
  end

  it "uses method name as the key" do
    dummy.no_key(123)
    Btrack.redis.getbit(Btrack::Helper.key("no_key", :daily, 3.days.ago), 123).should eq 1
  end
end