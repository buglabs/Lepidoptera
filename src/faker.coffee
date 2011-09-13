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
max_distance = .25
center_latitude = (buglabs.latitude - max_distance / 2)
center_longitude = (buglabs.longitude - max_distance / 2)
max_mpg = 70

#### Routing / API
#
# To start faking data to a random swarm listed in config.json, `GET /add`

app.get '/add', (req, res) ->
  fakeData()

# To start faking data to a specific swarm, `GET /add/:swarm_id`
app.get '/add/:swarm_id', (req, res) ->
  fakeData req.params.swarm_id

#### Helpers
#
# **fakeData** pushes fake data to a swarm
#
# Currently, it looks like
#
# `PUT /resources/:producer_name/feeds/mpg?swarm_id=:swarm_id`
#
# `{ latitude: -25.1, longitude: 40.1, mpg: 42 }`
#
# If you want to push other data, make sure the feed name and data field is the same, eg:
#
# `PUT /resources/:producer_name/feeds/RPM?swarm_id=:swarm_id`
#
# `{ latitude: -25.1, longitude: 40.1, RPM: 2600 }`

fakeData = (swarm) ->
  if swarm? and config.swarms.indexOf(swarm) > -1
    swarm_id = swarm
  else
    swarm_id = config.swarms[Math.floor(Math.random() * config.swarms.length)]

  options =
    host: config.host
    port: 80
    path: "/resources/#{config.producer_name}/feeds/mpg?swarm_id=#{swarm_id}"
    method: 'PUT'
    headers: { 'X-BugSwarmApiKey': config.producer_key }

  req = http.request options, (res) ->
    setInterval ->
      feed =
        latitude: center_latitude + Math.random() * max_distance
        longitude: center_longitude + Math.random() * max_distance
        mpg: Math.floor(Math.random() * max_mpg)
      req.write JSON.stringify feed
    , 5000
  req.write '\n'


process.on 'SIGTERM', ->
  process.exit 1

process.on 'SIGINT', ->
  process.exit 1

process.on 'exit', ->
  console.log 'sending presence "unavailable"'
  req.write JSON.stringify { presence: { type: "unavailable" } }


fakeData()
app.listen 33
