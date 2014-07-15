# Btrack

Btrack is an activity tracker with extensive query mechanism, minimum memory signature and maximum performance (thanks to redis)

With **Btrack** you can track any activity of any entity in your website or process

#### For example, tracking user logins (user 123 has just logged in):
`Btrack.track :logged_in, 123`

#### Query for total logins:
`Btrack.where(logged_in: :today).count`

#### Query if a specific user visited your website last month:
`Btrack.where(visited: :last_month, id: 123).exists?`

#### You can also plot a graph!
`Btrack.where(clicked_a_button: 1.week.ago..Time.now).plot`
`=> {"btrack:clicked_a_button:2014-07-06"=>10, "btrack:clicked_a_button:2014-07-07"=>5, "btrack:clicked_a_button:2014-07-08"=>30...`

#### or Cohort (for example, all users that signed in last week and visited this week )
`Btrack.where(signed_in: :last_week, visited: :this_week).plot`

# Background
**Btrack** uses Redis bitmaps to track activities over entities


## Installation

Add this line to your application's Gemfile:

    gem 'btrack'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install btrack

## Usage

## Basic tracking
## Granularity
## Tracking history
## Expiration time

## Basic querying
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
