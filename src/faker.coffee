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

# center latitude and longitude, max distance, and max mpg

buglabs = { latitude: 40.72498216901785, longitude: -73.99708271026611 }
max_distance = .25
center_latitude = (buglabs.latitude - max_distance / 2)
center_longitude = (buglabs.longitude - max_distance / 2)
max_mpg = 70

#### Resource Model
#
# Faker keeps track of a set of _resources_. A resource has an _id_, _timer_ id, and _stream_ handle.
#   ex: `'59c8f62e210812de2937d4700b6f751400546694': { timer: 27, stream: [Object stream] }

resources = {}

#### Routing / API
#
# push some fake data to an existing resource
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

# **push** sends data through the stream
push = (resource_id, latitude, longitude, mpg) ->
  console.log "pushing #{mpg}@#{latitude},#{longitude} from #{id}"
  resources["#{resource_id}"]?.stream?.write JSON.stringify { latitude: latitude, longitude: longitude, mpg: mpg }

# **addResource** adds a resource to a swarm, creates a stream for that connection and starts pushing fake data
addResource = (resource_id, swarm_id) ->
  console.log "adding #{resource_id} to #{swarm_id}"
  addResourceToSwarm resource_id, swarm_id if not resourceIsInSwarm resource_id
  addResourceToFaker resource_id, swarm_id if not resources["#{resource_id}"]?

# **resourceIsInSwarm checks that a resource exists in a given swarm
resourceIsInSwarm = (resource_id, swarm_id) ->
  swarms =
    JSON.parse
      request.get
        uri: "http://api.bugswarm.net/resources/#{resource_id}/swarms"
        headers: header

  exists = false
  exists = true if swarm.id is swarm_id for swarm in swarms
  return exists

# **addResourceToSwarm** adds a resource to a swarm
addResourceToSwarm = (resource_id, swarm_id) ->
  resource =
    id: resource_id
    user_id: jedahan
    type: producer

  request.post
    uri: "http://#{host}/swarms/#{swarm_id}/resources"
    headers: header
    json: JSON.stringify resource
    (error, response, body) ->
      console.error "  #{error}" if error?

# **addResourceToFaker** creates a handle to fake the data and start faking data if it does not exist
addResourceToFaker = (resource_id, swarm_id) ->
  resources["#{resource_id}"] =
    timer: fakeTimer resource_id
    stream: request.put
              uri: "http://#{host}/resources/#{user}/feeds/location?swarm_id=#{swarm_id}"
              headers: header
              (error, response, body) ->
                console.error "  #{error}" if error?
  resources["#{resource_id}"]?.stream?.write '\n'

# **fakeTimer** creates a timer to push fake data out every few seconds
fakeTimer = (resource_id) ->
  console.log "faking data for #{resource_id}"
  setInterval ->
    push resource_id, center_latitude + Math.random() * max_distance, center_longitude + Math.random() * max_distance, Math.floor(max_mpg * Math.random())
  , 5000


# we start with a randomly generated resource
addResource uuid().replace(/-/g, ''), '59c8f62e210812de2937d4700b6f751400546694'

app.listen 3030
