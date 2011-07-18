app = require('express').createServer()
jade = require 'jade'
http = require 'http'
stream = null

swarm =
  id: '59c8f62e210812de2937d4700b6f751400546694'
  key: '58528a20ff7b4e08f71213cfbe22daffd8c3b3d3'
  server: 'api.bugswarm-dev'
  user: 'jedahan'

# put /location/bugName with latitude and longitude in the request object
app.put '/location/:bug', (req,res) ->
  sendLocation req.latitude, req.longitude

# get /location/bugName/latitude/longitude works too
app.get '/location/:bug/:latitude,:longitude', (req, res) ->
  sendLocation req.params.latitude, req.params.longitude

# get /locations will show an updating map
app.get '/locations', (req, res) ->
  watchMap req, res

# sendLocation pushes out a new location for any bug
sendLocation = (latitude, longitude) ->
  console.log 'pushing out new location ' + latitude + ',' + longitude
  stream.write JSON.stringify { latitude: latitude, longitude: longitude }

# open the feed, whenever we get data send it through the socket
openLocationFeed = ->
  console.log 'opening location feed'

  options =
    host: swarm.server
    port: 80
    path: "/resources/producer1/feeds/location?swarm_id=#{swarm.id}"
    method: 'PUT'
    headers: {'X-BugSwarmApiKey': swarm.key }

  console.log 'we made the options hash'
  stream = http.request options, (res) ->
    console.log 'opening stream'

    setInterval ->
      console.log 'setting interval'
      sendLocation 40.0 + Math.random(), -73.0 + Math.random()
      return
    , 5000

  stream.write '\n'

# watchMap will only display new markers since the page was opened
watchMap = (req, res) ->
  console.log 'setting up keepalive connection'
  res.writeHead 200, "Content-Type": "text/html"
  setInterval ( -> res.write '\n'), 30000

  jade.renderFile 'map.jade', (error, html) ->
    console.log 'rendering jade'

    if error
      console.error 'error rendering jade'
      console.error '  ' + err
    else
      res.write html

app.listen 80

# bug since the jade doesn't render right :(
openLocationFeed()
