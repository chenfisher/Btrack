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

# use a cool shortcut
Btrack::Query.visited? 123, :today
```

#### You can also plot a graph!
``` ruby
Btrack.where(clicked_a_button: 1.week.ago..Time.now).plot
#=> {"2014-07-06"=>10, "2014-07-07"=>5, "2014-07-08"=>30...
```

#### Cohort analysis (for example, all users that signed in last week and visited this week )
```ruby
Btrack.where([{signed_in: :last_week}, {visited: :this_week}]).plot
```

# Background
**Btrack** uses Redis bitmaps to track activities over entities; you can track millions of users with a very small memory footprint and use bitwise operators to determine complex queries in realtime.

See relevant Redis commands for bitmaps here:
[http://redis.io/commands/SETBIT]

Read this to better understand how bitmaps work in redis and how you can use it for fast, realtime analytics: [http://blog.getspool.com/2011/11/29/fast-easy-realtime-metrics-using-redis-bitmaps/]


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
```ruby
Btrack.track "item:purchased", 1001
```

### Granularity
When tracking an event a default granularity is used (see **configuration** section for more details on default values);  the default granularity is :hourly..:monthly, which means :hourly, :daily, :weekly and :monthly

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


#### CAVEATS with granularities
You should be aware that there is a close relation between tracking and querying in regards to granularities. see **querying/granularity** section for more details.


```ruby
# track with daily granularity
Btrack.track :logged_in, 123, :daily

# query with weekly granualrity:
Btrack.where [{logged_in: :today, granularity: :weekly}]
#=> returns 0

# tracking with a range of granularities:
Btrack.track :logged_in, 123, :daily..:monthly

# now querying with weekly granularity is OK because it is included in the range:
Btrack.where [{logged_in: :today, granularity: :weekly}]
#=> returns 1
```
### Tracking with a block
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

### Tracking in the past tense
When tracking an event, the default time is ```Time.now``` which means: the event just happend.

You can specify a different time when tracking an event:
```ruby
Btrack::Tracker.track do |b|
  b.key = :logged_in
  b.id = 123
  b.when = 3.days.ago # this event happened 3 days ago
end
```

### Expiration time
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

```ruby
# Simple querying
Btrack.where(logged_in: :today).count
Btrack.where(logged_in: :yesteday).count
Btrack.where(logged_in: :last_week).count

# Query with a time range
Btrack.where(logged_in: 3.days.ago..Time.now).count
```

`Btrack.where` has the following form: `where(criteria, options={})`

**criteria** is an array of hashes, where each hash is the event to query and relevant optional options of that event (don't worry, there are plentty of examples in this section; just make sure to wrap the criteria with array and proper hashes when querying for more than one event or when specifying a granularity for an event)

**options={}** is preserved for feature use and is meant for specifying options that are not event specific

### Querying for a specific user/entity
```ruby
Btrack.where(logged_in: :today).exists? 123
#=> returns true if user 123 logged in today

Btrack.where(visited: 7.days.ago..Time.now)exists? 123
#=> returns true if user 123 visited the website in the past 7 days

# You can use a cool shortcut to query for a specific user:
Btrack::Query.visited? 123, 7.days.ago..Time.now
#=> same as above, but with a cool shortcut

Btrack::Query.logged_in? 123, :today
#=> true/false
```
### Lazyness
Queries are not "realized" until you perform an action:
```ruby
a_query = Btrack.where [logged_in: 1.week.ago..Time.now, granularity: :daily]
#=> <Btrack::Query::Criteria:0x007fceb248e120 @criteria=[{:logged_in=>:today}], @options={}>

a_query.count
#=> 3

a_query.exists? 123
#=> true

a_query.plot
#=> {"2014-07-06"=>10, "2014-07-07"=>5, "2014-07-08"=>30...

# You can use the "realize!" action to see what's under the hood
a_query.realize!
#=> [["btrack:logged_in:2014-07-11", "btrack:logged_in:2014-07-12", "btrack:logged_in:2014-07-13"...
```

### Intersection (querying for multiple events)
You can query for multiple events
```ruby
# signed in AND purchased something this month
q = Btrack.where([{signed_in: :this_month}, {purchased: :this_month}])

q.count
q.exists? 123
q.plot

# logged last week AND logged in today
Btrack.where([{logged_in: :last_week}, {logged_in: :today}])

# signed in the last 30 days, logged in this week and purchased something
Btrack.where([{signed_in: 30.days.ago..Time.now}, {logged_in: :last_week}, {purchased_something: :this_month}])
```

#### The & operator
You can use `&` for intersection
```ruby
signed_in = Btrack.where signed_in: 30.days.ago..Time.now
visited = Btrack.where visited: 7.days.ago..Time.now

signed_in_AND_visited = signed_in & visited
signed_in_visited_and_whatever = signed_in_AND_visited & Btrack.where(whatever: :today)
```

### Granularity
When querying, you should make sure you are tracking in the same granularity. If you are tracking in the range of :daily..:monthly then you can only query in that range (or you will get wrong results)

To specify the granualrity when querying, add a :granualrity key to the hash (per event):

```ruby
Btrack.where([{clicked_a_button: 3.hours.ago..Time.now, granularity: :hourly}])

# granularity is per event:
Btrack.where([{logged_in: 1.hour.ago..Time.now, granularity: :minute}, {did_something: :today, granularity: :daily}])

# see the next section (plotting) about granularity when plotting a graph
```

Another possible error you should be aware of is when querying for a timeframe that is not correlated with the granularity:

```ruby
# timeframe is :today, while granularity is :weekly
Btrack.where([{logged_in: :today, granularity: :weekly}])
# this will result in wrong results because :weekly granularity will refer
# to the whole week, while you probably meant to query only :today
```


> Default granularity when querying is the highest resolution set in configuration.default_granularity (:hourly..:monthly => :hourly is the default when querying)

## Plotting
Use `plot` to plot a graph
```ruby
# plot a graph with a daily resolution (granularity)
Btrack.where([{logged_in: 30.days.ago..Time.now, granularity: :daily}]).plot

# plot a graph with an hourly resolution
Btrack.where([{logged_in: 30.days.ago..Time.now, granularity: :hourly}]).plot
```

### Cohort
You can use what you've learned so far to create a cohort analysis
```ruby
visits = Btrack.where [visited: 30.days.ago..Time.now, granularity: :daily]
purchases = Btrack.where [purchased_something: 30.days.ago..Tome, granularity: :daily]

visits_and_purchases = visits & purchases

# now plot a cohort
visits_and_purchases.plot
#=> {"2014-06-23"=>10, "2014-07-16"=>20, "2014-07-05"=>5, "2014-06-26"=>0...

# NOTE that when plotting multiple events (cohort), the returned keys for the plot are named after the first event
```

## Configuration
Put this in an `initializer` to configure **Btrack**
```ruby
Btrack.config do |config|
  config.namespace = 'btrack' # default namespace for redis keys
  config.redis_url = nil # redis url to use; defaults to nil meaning localhost and default redis port
  config.expiration_for = {minute: 1.day, hourly: 1.week, daily: 3.months, weekly: 1.year, monthly: 1.year, yearly: 1.year}
  config.default_granularity: :daily..:monthly # default granularities when tracking
  config.silent = false # to break or not to break on redis errors
end
```

### namespace
Sets the namespace to use for the keys in redis; defaults to **btrack**

> keys in redis look like this: `btrack:logged_in:2014-07-15`
> 
>and in a general form: `namespace:event:datetime`

### expiration_for
Use expiration_for to set the expiration for a specific granularity
```ruby
Btrack.config.expiration_for = { daily: 7.months }
# will merge :daily expiration with the whole expirations hash
# {minute: 1.day, hourly: 1.week, daily: 7.months, weekly: 1.year, monthly: 1.year, yearly: 1.year}
```
### redis_url
Sets the connection url to the redis server; defaults to nil which means localhost and default redis port

## Alternatives
[Minuteman](https://github.com/elcuervo/minuteman) is a nice alternative to **Btrack** but with the following caveats (and more):

1. It does not support time frames (you cannot query for 30.days.ago..Time.now)
2. It eagerly creates a redis key on every bitwise operator, while **Btrack** is lazy
3. It uses redis `multi` while **Btrack** uses `lua` for better performance
4. No plot option in Minuteman

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
