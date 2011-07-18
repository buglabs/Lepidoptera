app = require('express').createServer()
jade = require 'jade'
request = require 'request'
uuid = require 'node-uuid'
DNode = require 'dnode'
stream = null
socket = require 'socket-io'

swarm =
  id: '59c8f62e210812de2937d4700b6f751400546694'
  key: '58528a20ff7b4e08f71213cfbe22daffd8c3b3d3'
  server: 'api.bugswarm-dev'
  user: 'jedahan'

# put /location/bugName with latitude and longitude in the request object
app.put '/location/:bug', (req,res) ->
  sendLocation req.params.bug, req.latitude, req.longitude

# get /location/bugName/latitude/longitude works too
app.get '/location/:bug/:latitude,:longitude', (req, res) ->
  sendLocation req.params.bug, req.params.latitude, req.params.longitude

# get /locations will show an updating map
app.get '/locations', (req, res) ->
  watchMap req, res

# sendLocation pushes out a new location for any bug
sendLocation = (bugName, latitude, longitude) ->
  console.log 'pushing out new location'
  stream.write JSON.stringify { latitude: latitude, longitude: longitude }

# open the feed and put it in the stream global
openLocationFeed = ->
  console.log 'opening location feed'
  request.put
    headers: { 'X-BugSwarmApiKey': swarm.key }
    url:    "http://#{swarm.server}/resources/android_demo/feeds/location?swarm_id=#{swarm.id}"
    json: { 'hi': 'hello' }
    onResponse: (body) ->
      sendLocation body.bugName, body.latitude, body.longitude
    (error, response, body) ->

      if error or response.statusCode != 200
        console.error 'error setting up feed'
        console.error '  ' + error

# watchMap will only display new markers since the page was opened
watchMap = (req, res) ->
  console.log 'creating temporary consumer'
  resource_url = "http://#{swarm.server}/swarms/#{swarm.id}/resources"
  consumer = { type: 'consumer', user_id: swarm.user, resource: uuid().replace(/\-/g,'') }

  request.post
    url: resource_url
    headers: { 'X-BugSwarmApiKey': swarm.key }
    json: consumer
    (error, response, body) ->
      if error or response.statusCode != 201
        console.error 'error creating temporary consumer'
        console.error '  ' + error

      console.log 'setting up keepalive connection'
      res.writeHead 200, "Content-Type": "text/html"
      setInterval ( -> res.write '\n'), 30000


      # note that the dnode server is started here
      jade.renderFile 'map.jade', (error, html) ->
        console.log 'rendering jade'

        if error
          console.error 'error rendering jade'
          console.error '  ' + err
        else
          res.write html

          console.log 'requesting feed'
          request
            headers: { 'X-BugSwarmApiKey': swarm.key }
            url: "http://#{swarm.server}/stream?swarm_id=#{swarm.id}&resource=android_demo"
            onResponse: (data) ->
              console.log data
            (error, response, body) ->
              console.log response
              if error is null or response.statusCode != 200
                console.log 'error requesting feed'
                console.log '  ' + error
              else
                response.on 'data', (data) ->
                  console.log 'calling remote.addNewLocation on data'
                  client = DNode.connect 6060, (remote) ->
                    console.log '  ' + data
                    remote.addNewLocation data
          

                response.on 'close', (data) ->
                  console.log 'removing temporary consumer '
                  request
                    url: resource_url
                    headers: { 'X-BugSwarmApiKey': swarm.key }
                    json: JSON.stringify consumer
                    ( error, response, body) ->
                      if error or response.statusCode != 200
                        console.error 'error removing temporary consumer'

app.listen 3000

DNode.listen app

openLocationFeed()
