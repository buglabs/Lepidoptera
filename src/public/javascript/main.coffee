window.initialize = ->
  console.log 'creating socketio server'

  try
    socket = io.connect 'http://api.bugswarm-dev'
  catch e
    console.log 'exception: ' + e

  socket.on 'connect', ->
    socket.emit 'apikey', '58528a20ff7b4e08f71213cfbe22daffd8c3b3d3'

  socket.on 'message', (message) ->
    addNewLocation JSON.parse message.message.body.data if message?.message?.body?.data?

  socket.on 'connected to backend', ->
    console.log 'connected'
    socket.emit 'message', {presence: {to: '59c8f62e210812de2937d4700b6f751400546694@swarms.xmpp.bugswarm-dev/browser'}}

  socket.on 'disconnect', ->
    console.log 'disconnected'

  socket.on 'error', (error) ->
    console.log 'ERROR: ' + JSON.stringify error


  console.log 'creating map centered around BUG Labs'
  mapOptions = zoom: 12, center: new google.maps.LatLng(40.72498216901785, -73.99708271026611) , mapTypeId: google.maps.MapTypeId.ROADMAP
  mapCanvas = document.getElementById "map_canvas"
  mapGoogle = new google.maps.Map mapCanvas, mapOptions

  markers = []

  addNewLocation = (location) ->
    marker = new google.maps.Marker
      position: new google.maps.LatLng location.latitude, location.longitude
      icon: "http://robohash.org/#{location.name}.png?size=40x40&set=set3"
      map: mapGoogle
      html: "<strong>#{location.name}</strong>"
      title: location.name

    infowindow = new google.maps.InfoWindow { content: 'testbug' }

    google.maps.event.addListener marker, 'click', () ->
      infowindow.setContent this.html
      infowindow.open mapGoogle, this

    markers.push marker
