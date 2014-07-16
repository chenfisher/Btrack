# Btrack

**Btrack** is an activity tracker with extensive query mechanism, minimum memory footprint and maximum performance (thanks to redis)

With **Btrack** you can track any activity of any entity in your website or process

#### Tracking user logins (user 123 has just logged in):
```ruby
Btrack.track :logged_in, 123
```

#### Query for total logins:
```ruby
Btrack.where(logged_in: :today).count
```

#### Query if a specific user visited your website last month:
```ruby
Btrack.where(visited: :last_month).exists? 123
```

#### You can also plot a graph!
``` ruby
Btrack.where(clicked_a_button: 1.week.ago..Time.now).plot
#=> {"btrack:clicked_a_button:2014-07-06"=>10, "btrack:clicked_a_button:2014-07-07"=>5, "btrack:clicked_a_button:2014-07-08"=>30...
```

#### Cohort analysis (for example, all users that signed in last week and visited this week )
```ruby
Btrack.where([{signed_in: :last_week}, {visited: :this_week}]).plot
```

# Background
**Btrack** uses Redis bitmaps to track activities over entities; you can track millions of users with a very small memory footprint and use bitwise operators to determine complex queries in realtime.

See relevant Redis commands for bitmaps here:
[http://redis.io/commands/SETBIT]

Read here to better understand how bitmaps work in redis and how you can use it for fast, realtime analytics: [http://blog.getspool.com/2011/11/29/fast-easy-realtime-metrics-using-redis-bitmaps/]


## Installation

Add this line to your application's Gemfile:

    gem 'btrack'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install btrack

## Usage

## Tracking
Basic tracking is done by specifying the event to track (can be a string or a symbol) and the id of the entity you are tracking (**must** be an interger)

User with id 123 purchased something:
```ruby
Btrack.track "user:purchased", 123
```
Item with id 1001 was just purchased:
Btrack.track "item:purchased", 1001

### Granularity
When tracking an event a default granularity is used (see **configuration** section for more details on default values);  the default granularity is :daily, which means that tracking an event twice on the same day will result in only 1 bit:
```ruby
# The time is 11.00am and user 123 has just logged in:
Btrack.track :logged_in, 123

# The time is 19.00 and the same user (123) has just logged in:
Btrack.track :logged_in, 123

# Now when we query for logins, we get the unique login count for the day:
Btrack.where(logged_in: :today).count
#=> 1
```

To track with a different granualrity:
```ruby
# track with a weekly granularity
Btrack.track :logged_in, 123, :weekly

# track with both daily and weekly granularity:
Btrack.track :logged_in, 123, [:daily, :weekly]

# track with a range of granularities:
Btrack.track :logged_in, 123, :hourly..:monthly
#=> will track with: hourly, daily, weekly and monthly
```

Available granularities: [:minute, :hourly, :daily, :weekly, :monthly, :yearly]


#### Why is that important?

When querying an event with granualrity other than the one used for tracking - you will get wrong results. For example, tracking with a daily granularity while querying with a weekly granualrity.


```ruby
# track with daily granularity
Btrack.track :logged_in, 123, :daily

# query with weekly granualrity:
Btrack.where logged_in: :today, granularity: :weekly
#=> returns 0

# tracking with a range of granularities:
Btrack.track :logged_in, 123, :daily..:monthly

# now querying with weekly granularity is OK because it is included in the range:
Btrack.where logged_in: :today, granularity: :weekly
#=> returns 1
```
## Tracking with a block
You can track with a block for convenience and for specifying other tracking options:

```ruby
Btrack::Tracker.track do |b|
  b.key = "logged_in"
  b.id = 123
  b.granularity = :daily..:monthly
  b.when = 3.days.ago # when was this event occured
  b.expiration_for = { daily:6.days } # specify expiration for this event
end
```

## Tracking history
When tracking an event, the default time is ```Time.now``` which means: the event just happend.

You can specify a different time when tracking an event:
```ruby
Btrack::Tracker.track do |b|
  b.key = :logged_in
  b.id = 123
  b.when = 3.days.ago # this event happened 3 days ago
end
```

## Expiration time
You can specity retention for events per granularity. Use this to get rid of granularities you don't need any more and save memory (in redis)

```ruby
Btrack::Tracker.track do |b|
  b.key = :logged_in
  b.id = 123
  b.expiration_for = { minute: 3.days, daily: 3.months } 
  # after 3 days all "minute" granularities for this event will be deleted 
  # and 3 months later all the relevant "daily" granularities will be deleted
end
```

## Querying
## Specific user
## Granularity
## Chaining

## Plotting
## Granularity
## Cohort

## Configuration
## namespace
## expiration_for
## redis_url


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
