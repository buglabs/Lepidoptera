#### Faker
#
# **Faker** is a library for sending fake data to a swarm

http = require 'http'
express = require 'express'
app = express.createServer()
config = JSON.parse require('fs').readFileSync './config.json', 'utf8'

#### Constants

# center latitude and longitude, max distance, and max mpg

buglabs = { latitude: 40.72498216901785, longitude: -73.99708271026611 }
max_distance = .25
center_latitude = (buglabs.latitude - max_distance / 2)
center_longitude = (buglabs.longitude - max_distance / 2)
max_mpg = 70

#### Routing / API
#
# start faking data to a random swarm
app.get '/add', (req, res) ->
  fakeData()

# start faking data to a specific swarm
app.get '/add/:swarm', (req, res) ->
  fakeData req.params.swarm

#### Helpers
#
# **fakeData** pushes fake data to a swarm
fakeData = (swarm) ->
  if swarm? and config.swarms.indexOf(swarm) > -1
    swarm_id = swarm
  else
    swarm_id = config.swarms[Math.floor(Math.random() * config.swarms.length)]

  options =
    host: config.host
    port: 80
    path: "/resources/#{config.producer_name}/feeds/location?swarm_id=#{swarm_id}"
    method: 'PUT'
    headers: { 'X-BugSwarmApiKey': config.producer_key }

  req = http.request options, (res) ->
    setInterval ->
      feed =
        latitude: center_latitude + Math.random() * max_distance
        longitude: center_longitude + Math.random() * max_distance
        mpg: Math.floor(Math.random() * max_mpg)
      req.write JSON.stringify feed
    , 500
  req.write '\n'

fakeData()
app.listen 33
