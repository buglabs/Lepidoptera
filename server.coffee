app = require('express').createServer()
jade = require 'jade'
request = require 'request'

swarm.id     = ''
swarm.key    = ''
swarm.server = 'api.bugswarm-test'

# FIXME: use put next time
app.get '/location/:bug/:latitude,:longitude', (req, res) ->
  
  request.put { header:'X-BugSwarmApiKey: #{swarm.key}', url:'http://#{swarm.server}/swarms/id=#{swarm.id}&feed=#{req.params.bug}', json:'{"latitude":#{req.params.latitude}, "longitude":#{req.params.longitude}}' }, (error, response, body) ->

    if not error and response.statusCode == 200
      console.log 'sending #{latitude}, #{longitude} for #{bug}'
      
app.get '/locations', (req, res) ->
  # FIXME: write header with content-length, status-code, content-typ

  # Keep the connection alive
  setInterval (() -> res.write '\n'), 30000

  # Setup the blank page
  renderEmptyMap
 
  # open a stream listening for any locations
  request { url:'http://#{swarm.server}/#{swarm.key}/#{swarm.id}/feeds?stream=true' }, (error, response, body) ->
    if not error and response.statusCode == 200
      console.log 'stream connected successfully'

      response.on 'data', (data) ->
        console.log 'got data: ' + data
        addNewLocation data



renderEmptyMap = () ->
  console.log 'rendering map.jade'

  jade.renderFile 'map.jade', (err, html) ->
    not err and res.write html

  console.log 'adding blank map'

  buglabs = new google.maps.LatLng 70.0, -74.0
  mapOptions = { zoom: 7, center: buglabs, mapTypeId: google.maps.MapTypeId.TERRAIN }
  mapCanvas = document.getElementById("map_canvas")
  map = new google.maps.Map mapCanvas, mapOptions

addNewLocation = (data) ->
  console.log 'adding marker for ' + data.bug
  
  marker = new google.maps.Marker({
    position: new location(data.latitude, data.longitude),
    map: map,
    title: data.bug,
    html: "<strong>"+data.bug+"</strong>"
  })
  
  infowindow = google.maps.InfoWindow {
    content: data.bug
  }
  
  popup = () ->
    infowindow.setContent(this.html)
    infowindow.open(map, this)
  google.maps.event.addListener marker, 'click', popup
  
  markers.push marker
  
app.listen 3000
