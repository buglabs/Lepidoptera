app = require('express').createServer()
jade = require 'jade'
request = require 'request'

swarm.id     = ''
swarm.key    = ''
swarm.server = 'api.bugswarm-test'

app.put '/location/:bug/:lat,:lon', (req, res) ->
  request.put { header:'X-BugSwarmApiKey: #{swarm.key}',
		uri:'http://#{swarm.server}/swarms/id=#{swarm.id}&feed=#{req.params.bug}' }, (error, response, body) ->

    if not error and response.statusCode == 200
      console.log 'sent #{latitude}, #{longitude} for #{bug}'
      
    return

app.get '/locations', (req, res) ->
  # FIXME: write header with content-length, status-code, content-typ

  # Keep the connection alive
  setInterval (() -> res.write '\n'), 30000

  # Setup the blank page
  renderEmptyMap
 
  # open a stream listening for any locations
  request { uri:'http://#{swarm.server}/#{swarm.key}/#{swarm.id}/feeds?stream=true' }, (error, response, body) ->
    if not error and response.statusCode == 200
      response.on 'data', (data) ->
        res.write data
        res.write '\n'
        console.log data

      console.log JSON.parse(body)
  
    return

  res.on 'data', addNewLocation data

renderEmptyMap = () ->
  jade.renderFile 'map.jade' (err, html) ->
    res.write html

  # Add a map to the page
  buglabs = new google.maps.LatLng 0, -180
  mapOptions = { zoom: 7, center: buglabs, mapTypeId: google.maps.MapTypeId.TERRAIN }
  mapCanvas = document.getElementById("map_canvas")
  map = new google.maps.Map mapCanvas, mapOptions
  return 

addNewLocation = (data) ->
  marker = new google.maps.Marker({
    position: new location(data.latitude, data.longitude),
    map: map,
    title: data.bug,
    html: "<strong>"+data.bug+"</strong>"
  })

  infowindow = google.maps.InfoWindow {
    content: data.bug
  }

  google.maps.event.addListener(marker, 'click', () ->
    infowindow.setContent(this.html)
    infowindow.open(map, this)
  
  markers.push marker


app.listen 3000
