#
#### Lepidoptera
#
# **Lepidoptera** is an example solution built on top of [Swarm](http://github.com/buglabs/swarm).
#
# It is a visualization of fleet movement that can help to quickly
# identify and answer high level questions like
#
#    * how many people are sleeping?
#    * which drivers are the most efficient?
#    * are there any areas that are more difficult to get to?
#
#    etc...
#

#
#### Installation
#
# To get Lepidoptera up and running, first make sure you have
# [Node.js](http://nodejs.org/) (`brew install node`) and
# [npm](http://npmjs.org) (`curl http://npmjs.org/install.sh | sh`).
# Then, just:
#
#     npm install
#     npm install supervisor -g
#     supervisor src/*coffee
#
# Now browse `http://localhost/locations` to witness the magic
#

#### Server
#
# The webserver keeps a lightweight model of the swarm in memory, and is responsible
# for passing any important messages and events to the frontend when rendering.
#
# In addition, this server supports populating swarms with fake data
#
express = require 'express'
app = express.createServer()
jade = require 'jade'
http = require 'http'
request = require 'request'

host = 'api.bugswarm-dev'
header = { 'X-BugSwarmApiKey': '58528a20ff7b4e08f71213cfbe22daffd8c3b3d3' }

buglabs = { lat: 40.72498216901785, lon: -73.99708271026611 }

#
# Add a contains method to strings :)
#
String.prototype.contains = (it) ->
  this.indexOf it is not -1

#
# The internal swarm model contains a name, unique id and most importantly a handle to the stream
#
swarms = []

#
# **addSwarm** checks for duplicate swarms before adding one
#
addSwarm = (id, name) ->
  if (name.id=1? for name in swarms)[0]
    console.error 'swarm ' + id + ' already exists!'
  else
    swarms.push
      id: id
      name: name
      stream: null

#
#### Routing / API
#
# To push your own location data, use `put /location/:swarm_id` with
# latitude and longitude in the request.
# The server also supports a get request in the form of
# `get /location/:swarm/:latitude/:longitude`
#
# To add a new swarm, do `get /swarm/add/:id/:name`
#
app.put '/location/:swarm_id', (req,res) ->
  sendLocation req.params.swarm_id, req.latitude, req.longitude

app.get '/location/:swarm_id/:latitude,:longitude', (req, res) ->
  sendLocation req.params.swarm_id, req.params.latitude, req.params.longitude

app.get '/swarm/add/:id/:name', (req,res) ->
  addSwarm req.params.id, req.params.name

#
# To see a map of all the location feeds, `get /locations`
#
app.get '/locations', (req, res) ->
  watchMap req, res

#
#### Helper Methods
#
# **sendLocation** pushes out a new location to a swarm
sendLocation = (swarm_id, latitude, longitude) ->
  for swarm in swarms
    if swarm.id is swarm_id
      swarm.stream.write JSON.stringify { name: swarm.name, latitude: latitude, longitude: longitude }

#
# **startFakeStream** pushes out fake locations to a swarm every few seconds
#
startFakeStream = (swarm) ->
  console.log 'Starting fake stream for ' + swarm.name + ' swarm'
  size = .25
  lat = buglabs.lat - size / 2
  lon = buglabs.lon - size / 2

  setInterval ->
    sendLocation swarm.id, lat + Math.random() * size, lon + Math.random() * size
  , 5000


#
# **openLocationFeed** starts the connection for each swarm stream if necessary.
# A bonus feature, if your swarm name contains the word `fake` the server will start generating random data!
#
openLocationFeed = ->
  console.log 'opening location feed'

  for swarm in swarms
    console.log swarm
    swarm.stream ?= request.put
      uri: "http://#{host}/resources/producer1/feeds/location?swarm_id=#{swarm.id}"
      headers: header
      (error, response, body) ->
        console.error '  ' + error if error?

    swarm.stream.write '\n'
    if swarm.name.contains 'fake'
      startFakeStream swarm

#
# **watchMap** renders the frontend, displaying markers for each new location
# sent to a swarm **since the page was opened**
#
watchMap = (req, res) ->
  console.log 'setting up keepalive connection'
  res.writeHead 200, "Content-Type": "text/html"
  setInterval ( -> res.write '\n'), 30000

  jade.renderFile 'src/map.jade', (error, html) ->
    console.log 'rendering jade'

    if error
      console.error '  ' + error
    else
      res.write html

addSwarm '59c8f62e210812de2937d4700b6f751400546694', 'fakeOne'

app.use express.static(__dirname + '/public')
app.use app.router
app.listen 80

openLocationFeed()
