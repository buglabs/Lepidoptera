#### Faker
#
# **Faker** is a library for sending fake data to a swarm
#
# To add a new fake resource, pushing data out to swarm _S_, GET `/resources/new/_S_`
#   This will return a newly generated resource id reffered to as _R_
#
# To push a fake location from resource _R_, GET `/resources/_R_/push/:latitude,:longitude,:mpg`
# To stop faking data for a resource _R_, GET `/resources/_R_/unfake`
# To start faking data again for resource _R_, GET `/resources/_R_/fake`

express = require 'express'
request = require 'request'
uuid = require 'node-uuid'
app = express.createServer()

#### Constants
#
# host is the uri for the swarm server, header contains the api key for user

host = 'bugswarm.net'
port = 8888
user = 'producer1'
header = { 'X-BugSwarmApiKey': '58528a20ff7b4e08f71213cfbe22daffd8c3b3d3' }

# constants for faking location and mpg

buglabs = { lat: 40.72498216901785, lon: -73.99708271026611 }
delta = .25
lat = (buglabs.lat - delta / 2)
lon = (buglabs.lon - delta / 2)
mpg = 70

#### Resource Model
#
# Faker keeps track of a set of _resources_. A resource has an _id_, _timer_ id, and _stream_ handle.
#   ex: `'59c8f62e210812de2937d4700b6f751400546694': { timer: 27, stream: [Object stream] }

resources = {}

#### Routing / API
#
# push some fake data to an existing rersource

app.get '/resources/:id/push/:latitude,:longitude,:mpg', (req, res) ->
  push req.params.id, req.params.latitude, req.params.longitude, req.params.mpg

# create a new fake resource that will automatically start faking data
# returns the resource _id_

app.get '/resources/new/:swarm', (req,res) ->
  res.write addResource uuid().replace(/-/g, ''), req.params.swarm

# start faking data for an existing resource

app.get '/resources/:id/fake', (req, res) ->
  resources["#{req.params.id}"]?.timer ?= fakeTimer req.params.id

# stop faking data for an existing resource

app.get '/resources/:id/unfake', (req, res) ->
  clearInterval resources["#{req.params.id}"]?.timer

#### Helper Methods
#
# **push** sends data through the stream

push = (id, latitude, longitude, mpg) ->
  console.log "pushing #{mpg}@#{latitude},#{longitude} from #{id}"
  resources["#{id}"]?.stream?.write JSON.stringify { latitude: latitude, longitude: longitude, mpg: mpg }

# **addResource** creates a new resource and adds it to a swarm

addResource = (id, swarm) ->
  console.log "adding #{id} to #{swarm}"
  if resources["#{id}"]?
    console.error "Resource #{id} already exists!"
  else
    resources["#{id}"] =
      timer: fakeTimer id
      stream: request.put
                uri: "http://#{host}/resources/#{user}/feeds/location?swarm_id=#{swarm}"
                headers: header
                (error, response, body) ->
                  console.error '  ' + error if error?
    resources["#{id}"]?.stream?.write '\n'
  return id


# **fakeTimer** creates a timer to push fake data out every few seconds

fakeTimer = (id) ->
  console.log "faking #{id}"
  setInterval ->
    push id, lat + Math.random() * delta, lon + Math.random() * delta, Math.floor(mpg * Math.random())
  , 5000


addResource uuid().replace(/-/g, ''), '59c8f62e210812de2937d4700b6f751400546694'

app.listen 3030
