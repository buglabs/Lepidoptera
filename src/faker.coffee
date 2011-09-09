#### Faker
#
# **Faker** is a library for sending fake data to a swarm
#

http = require 'http'
express = require 'express'
app = express.createServer()
config = JSON.parse require('fs').readFileSync './config.json', 'utf8'

#### Constants
#
# center latitude and longitude, max distance, and max mpg

buglabs = { latitude: 40.72498216901785, longitude: -73.99708271026611 }
techcrunch = { latitude: 37.770053, longitude: -122.403799 }

max_distance = .01
center_latitude = (techcrunch.latitude - max_distance / 2)
center_longitude = (techcrunch.longitude - max_distance / 2)
cars = [ { name: "Fiesta", count: 0 }, { name: "Fusion", count: 0 } ]
reqs = []

#### Routing / API
#
# To start faking data to a random swarm listed in config.json, `GET /add`

app.get '/add', (req, res) ->
  fakeData()

app.get '/:feed', (req, res) ->
  fakeData req.params.feed

# To start faking data to a specific swarm, `GET /add/:swarm_id`
app.get '/:feed/:swarm_id', (req, res) ->
  fakeData req.params.feed, req.params.swarm_id

#### Helpers
#
# **fakeData** pushes fake data to a swarm
#
# Currently, it looks like
#
# `{ latitude: -25.1, longitude: 40.1, mpg: 42, rpm: 2600, ... }`
#

fakeData = (feed_name="ford", swarm_id=config.swarms[Math.floor(Math.random() * config.swarms.length)]) ->
  if config.swarms.indexOf(swarm_id) > -1
    options =
      host: config.host
      port: 80
      path: "/resources/#{config.producer_name}/feeds/#{feed_name}?swarm_id=#{swarm_id}"
      method: 'PUT'
      headers: { 'X-BugSwarmApiKey': config.producer_key }

    car = cars[Math.floor(Math.random() * cars.length)]
    car_name = "#{car.name} #{++car.count}"

    req = http.request options, (res) ->
      setInterval ->
        feed =
          car_name: car_name
          latitude: center_latitude + Math.random() * max_distance
          longitude: center_longitude + Math.random() * max_distance
        for feeder in config.feeds
          feed[feeder.name] = Math.floor(Math.random() * feeder.max)
        req.write JSON.stringify feed
      , 5000
    req.write '\n'
    reqs.push req

process.on 'SIGTERM', ->
  process.exit 1

process.on 'SIGINT', ->
  process.exit 1

process.on 'exit', ->
  console.log 'sending presence unavailable'
  for req in reqs
    req.end

fakeData()
app.listen 33
