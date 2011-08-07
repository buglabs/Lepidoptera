#### Faker
#
# **Faker** is a library for sending fake data to a swarm

express = require 'express'
request = require 'request'
uuid = require 'node-uuid'
app = express.createServer()

#### Constants
#
# host is the uri for the swarm server, header contains the api key for user

host = '107.20.250.52'
user = 'web'
header = { 'X-BugSwarmApiKey': 'eae9f2188a375c4635138928b93c4b9f97d30803' }

# center latitude and longitude, max distance, and max mpg

buglabs = { latitude: 40.72498216901785, longitude: -73.99708271026611 }
max_distance = .25
center_latitude = (buglabs.latitude - max_distance / 2)
center_longitude = (buglabs.longitude - max_distance / 2)
max_mpg = 70

# the resource we are going to use for all swarm connections

resource =
  id: uuid().replace(/-/g, '')
  user_id: "jedahan"
  name: "fake"
  type: "producer"
  description: "test"
  machine_type: "bug"

# the list of connections
connections = []

# the list of swarms we are interested in

swarms = []
swarms.push '142424f0919542c4fb60bbda4a254be645396ee9'
swarms.push 'f62597e0eebe026dfc000b2931245b7b02be266c'
swarms.push 'b66dbbc74e2b1de4bde41bf353ceeb85cdd36bb6'

#### Routing / API
#
# push some fake data to a swarm
app.get '/swarms/:swarm_id/push/:latitude,:longitude,:mpg', (req, res) ->
  push req.params.swarm_id, req.params.latitude, req.params.longitude, req.params.mpg

# create a new fake connection that will automatically start faking data
app.get '/connect/:swarm', (req, res) ->
  addConnection req.params.swarm

#### Helper Methods

# **push_data** sends data through the stream
push_data = (swarm_id, latitude, longitude, mpg) ->
  console.log "push_data #{mpg}@#{latitude},#{longitude} to #{swarm_id}"
  for connection in connections
    console.log connection
  #stream = connection.stream if connection.swarm is swarm_id for connection in connections
  #stream.write(JSON.stringify({ latitude: latitude, longitude: longitude, mpg: mpg }))

# **resourceIsInSwarm checks that a resource exists in a given swarm
resourceIsInSwarm = (swarm_id) ->
  console.log "resourceIsInSwarm(#{swarm_id})"
  message = {}

  request.get
    uri: "http://#{host}/resources/#{resource.id}/swarms"
    headers: header
    (error, body, response) ->
      message = body

  if (not message?.id?) or (message?.httpCode is 404)
    return false

  exists = false
  exists = true if message?.id is swarm_id for swarm in swarms
  return exists

# **addConnection** adds the resource to a swarm
addConnection = (swarm_id) ->
  console.log "addConnection(#{swarm_id})"
  request.post
    uri: "http://#{host}/swarms/#{swarm_id}/resources"
    headers: header
    json: resource
    (error, response, body) ->
      console.error "  #{error}" if error?

# **startFakingData** starts sending data to a feed
startFakingData = (swarm_id) ->
  console.log "startFakingData(#{swarm_id})"
  connections.push
    swarm: swarm_id
    timer: fakeTimer swarm_id
    stream: request.put
      uri: "http://#{host}/resources/#{resource.id}/feeds/location?swarm_id=#{swarm_id}"
      headers: header
      (error, response, body) ->
        console.error "  #{error}" if error?
  connections[connections.length-1].stream?.write '\n'

# **fakeTimer** creates a timer to push fake data out every few seconds
fakeTimer = (swarm_id) ->
  console.log "fakeTimer()"
  setInterval ->
    push_data swarm_id, center_latitude + Math.random() * max_distance, center_longitude + Math.random() * max_distance, Math.floor(max_mpg * Math.random())
  , 5000

# **addResource** adds a resource to a swarm, creates a stream for that connection and starts pushing fake data
addResource = (swarm_id) ->
  console.log "addResource #{swarm_id}"
  if not resourceIsInSwarm(swarm_id)
    addConnection(swarm_id)
  startFakingData(swarm_id)

addResource swarms[0]
app.listen 33
