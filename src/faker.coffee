#### Faker
#
# **Faker** is a library for sending fake data to a swarm
#

#### Constants
#
# center latitude and longitude, max distance, and max mpg

#### Routing / API
#
# To start faking data to a random swarm listed in config.json, `GET /add`

#### Helpers
#
# **fakeData** pushes fake data to a swarm
#
# Currently, it looks like
#
# `{ latitude: -25.1, longitude: 40.1, mpg: 42, rpm: 2600, ... }`
#
reqs = []

fakeData = (config) ->
  feed_name="ford"
  swarm_id=config.swarms[Math.floor(Math.random() * config.swarms.length)]
  http = require 'http'
  max_distance = .01
  center_latitude = (config.techcrunch.latitude - max_distance / 2)
  center_longitude = (config.techcrunch.longitude - max_distance / 2)
  cars = [ { name: "Fiesta", count: 0 }, { name: "Fusion", count: 0 } ]

  if config.swarms.indexOf(swarm_id) > -1
    options =
      host: config.host
      port: 80
      path: "/resources/#{config.producer_name}/feeds/#{feed_name}?swarm_id=#{swarm_id}"
      method: 'PUT'
      headers: { 'X-BugSwarmApiKey': config.producer_key }

    car = cars[Math.floor(Math.random() * cars.length)]

    req = http.request options, (res) ->
      setInterval ->
        feed =
          car_name: car.name
          latitude: center_latitude + Math.random() * max_distance
          longitude: center_longitude + Math.random() * max_distance
        for feeder in config.feeds
          feed[feeder.name] = Math.floor(Math.random() * feeder.max)
        req.write JSON.stringify feed
      , 3000 + (Math.random() * 2000)
    req.write '\n'
    reqs.push req

removeFaker = ->
  reqs[Math.floor(Math.random() * reqs.length)].end

module.exports.add = fakeData
module.exports.remove = removeFaker

