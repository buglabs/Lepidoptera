#### Faker
#
# **Faker** is a library for sending fake data to a swarm

http = require 'http'
express = require 'express'
uuid = require 'node-uuid'
app = express.createServer()
config = JSON.parse require('fs').readFileSync './config.json', 'utf8'

#### Constants

# center latitude and longitude, max distance, and max mpg

buglabs = { latitude: 40.72498216901785, longitude: -73.99708271026611 }
max_distance = .25
center_latitude = (buglabs.latitude - max_distance / 2)
center_longitude = (buglabs.longitude - max_distance / 2)
max_mpg = 70

# the list of swarms we are interested in

swarms = []
swarms.push id for id in config.swarms

#### Routing / API
#
# create a new fake connection that will automatically start faking data
app.get '/add', (req, res) ->
  addResource req.params.swarm

#### Helpers
#
# **addResource** creates a feed for a swarm and starts pushing fake data
addResource = ->
  swarm_id = swarms[Math.floor(Math.random() * 2)]
  resource_id = uuid().replace(/-/g,'')

  options =
    host: config.host
    port: 80
    path: "/resources/#{resource_id}/feeds/location?swarm_id=#{swarm_id}"
    method: 'PUT'
    headers: { 'X-BugSwarmApiKey': config.api_key }

  req = http.request options, (res) ->
    interval = setInterval ->
        feed =
          latitude: center_latitude + Math.random() * max_distance
          longitude: center_longitude + Math.random() * max_distance
          mpg: Math.floor(Math.random() * max_mpg)
        req.write JSON.stringify feed
      , 5000
  req.write '\n'

  , 5000

addResource swarms[0]
app.listen 33
