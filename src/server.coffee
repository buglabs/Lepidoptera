express = require 'express'
app = express.createServer()
jade = require 'jade'
http = require 'http'
request = require 'request'

host = 'api.bugswarm-dev'
header = { 'X-BugSwarmApiKey': '58528a20ff7b4e08f71213cfbe22daffd8c3b3d3' }

# Swarms contain a name, id and stream handle
swarms = []
swarms.push
  id: '59c8f62e210812de2937d4700b6f751400546694'
  name: 'fake'
  stream: null

# for static pages
app.use express.static(__dirname + '/public')
app.use app.router

# To push your own location data, use 'put /location/:swarm_id' with latitude and longitude in the request
app.put '/location/:swarm_id', (req,res) ->
  sendLocation req.params.swarm_id, req.latitude, req.longitude

# To push fake location data, 'get /location/:swarm/:latitude/:longitude'
app.get '/location/:swarm_id/:latitude,:longitude', (req, res) ->
  sendLocation req.params.swarm_id, req.params.latitude, req.params.longitude

# To see a map of all the location feeds, 'get /locations'
app.get '/locations', (req, res) ->
  watchMap req, res

# sendLocation pushes out a new location for any swarm
sendLocation = (swarm_id, latitude, longitude) ->
  swarm = swarms[id=swarm_id]
  swarm.stream.write JSON.stringify { name: swarm.name, latitude: latitude, longitude: longitude }

# openLocationFeed starts the connection for each swarm stream if necessary
#   if the swarm name contains 'fake' then it will start populating that feed with fake data
openLocationFeed = ->
  console.log 'opening location feed'

  for swarm in swarms
    swarm.stream ?= request.put
      uri: "http://#{host}/resources/producer1/feeds/location?swarm_id=#{swarm.id}"
      headers: header
      (error, response, body) ->
        swarm.stream.write '\n'
        # start writing our fake data
        if swarm.name.contains 'fake'
          startFakeStream swarm

# startFakeStream Starts pushing fake locations through a swarm feed
startFakeStream = (swarm) ->
  console.log 'Starting fake stream for ' + swarm.name + ' swarm'
  size = .25
  x = 40.72498216901785 - size / 2
  y = -73.99708271026611 - size / 2

  setInterval ->
    sendLocation swarm.id, x + Math.random() * size, y + Math.random() * size
  , 5000

# watchMap will display markers of any new locations pushed since the page was opened
watchMap = (req, res) ->
  console.log 'setting up keepalive connection'
  res.writeHead 200, "Content-Type": "text/html"
  setInterval ( -> res.write '\n'), 30000

  jade.renderFile 'map.jade', (error, html) ->
    console.log 'rendering jade'

    if error
      console.error 'error rendering jade'
      console.error '  ' + error
    else
      res.write html

app.listen 80

# BUG: explicitly call openLocationFeed otherwise the map wont render
openLocationFeed()
