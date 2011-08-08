#### Faker
#
# **Faker** is a library for sending fake data to a swarm

http = require 'http'
express = require 'express'
uuid = require 'node-uuid'
app = express.createServer()

#### Constants

# center latitude and longitude, max distance, and max mpg

buglabs = { latitude: 40.72498216901785, longitude: -73.99708271026611 }
max_distance = .25
center_latitude = (buglabs.latitude - max_distance / 2)
center_longitude = (buglabs.longitude - max_distance / 2)
max_mpg = 70

# the list of swarms we are interested in

swarms = []
swarms.push '142424f0919542c4fb60bbda4a254be645396ee9'
swarms.push 'b66dbbc74e2b1de4bde41bf353ceeb85cdd36bb6'

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
  console.log swarm_id
  resource_id = uuid().replace(/-/g,'')

  options =
    host: '107.20.250.52'
    port: 80
    path: "/resources/#{resource_id}/feeds/location?swarm_id=#{swarm_id}"
    method: 'PUT'
    headers: { 'X-BugSwarmApiKey': 'eae9f2188a375c4635138928b93c4b9f97d30803'}

  req = http.request options, (res) ->
    interval = setInterval ->
        feed =
          latitude: center_latitude + Math.random() * max_distance
          longitude: center_longitude + Math.random() * max_distance
          mpg: Math.floor(max_mpg * Math.random())
        req.write JSON.stringify feed
      , 5000
  req.write '\n'

  , 5000

addResource swarms[0]
app.listen 33
