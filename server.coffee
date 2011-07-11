app = require('express').createServer()
jade = require 'jade'
request = require 'request'

swarm.id     = ''
swarm.key    = ''
swarm.server = 'api.bugswarm-test'

# put /location/bugName with latitude and longitude in the request object
app.put '/location/:bug', (req,res) ->
  sendLocation req.params.bug, req.latitude, req.longitude

# get /location/bugName/latitude/longitude works too
app.get '/location/:bug/:latitude,:longitude', (req, res) ->
  sendLocation req.params.bug, req.params.latitude, req.params.longitude

sendLocation = (bugName, latitude, longitude) ->
  request.put
    header: 'X-BugSwarmApiKey: #{swarm.key}'
    url:    'http://#{swarm.server}/swarms/id=#{swarm.id}&feed=#{bugName}'
    json:   '{"latitude":#{latitude}, "longitude":#{longitude}}'
    (error, response, body) ->

      if not error and response.statusCode == 200
        console.log 'sending #{latitude}, #{longitude} for #{bug}'

# this will only show new requests since the page was opened
app.get '/locations', (req, res) ->
  # write the correct header
  response.writeHead 200, "Content-Type": "text/html"

  # keep the connection alive
  setInterval (() -> res.write '\n'), 30000

  # setup the blank page
  renderEmptyMap
 
  # open a stream listening for any locations
  request url:'http://#{swarm.server}/#{swarm.key}/#{swarm.id}/feeds?stream=true', (error, response, body) ->
    if not error and response.statusCode == 200
      console.log 'swarm feed connected'

      response.on 'data', (data) ->
        console.log 'recieved feed data: ' + data
        addNewLocation data



renderEmptyMap = () ->
  console.log 'rendering map.jade'

  jade.renderFile 'map.jade', (err, html) ->
    not err and res.write html

  console.log 'adding blank map'

  buglabs = new google.maps.LatLng 70.0, -74.0
  mapOptions = zoom: 7, center: buglabs, mapTypeId: google.maps.MapTypeId.TERRAIN
  mapCanvas = document.getElementById "map_canvas"
  map = new google.maps.Map mapCanvas, mapOptions

addNewLocation = (data) ->
  console.log 'adding marker for ' + data.bug
  
  marker = new google.maps.Marker
    position: new google.maps.LatLng data.latitude, data.longitude
    map: map
    title: data.bug
    html: "<strong>" + data.bug + "</strong>"
  
  infowindow = google.maps.InfoWindow content: data.bug
  
  google.maps.event.addListener marker, 'click', () ->
    infowindow.setContent this.html
    infowindow.open map, this
  
  markers.push marker
  
app.listen 3000
