window.initialize = ->
  console.log "config: #{JSON.stringify config}"

  console.log 'creating map centered around BUG Labs'
  mapOptions = zoom: 12, center: new google.maps.LatLng(40.72498216901785, -73.99708271026611) , mapTypeId: google.maps.MapTypeId.ROADMAP
  mapCanvas = document.getElementById "map_canvas"
  mapGoogle = new google.maps.Map mapCanvas, mapOptions

  markers = []

  processMessage = (message) ->
    if message?.message?.body?.data?
      addNewLocation(JSON.parse message.message.body.data)
    else
      console.log "message: #{JSON.stringify message}"

  console.log "consumer key: #{config.consumer_key}"
  console.log "swarms: #{config.swarms}"
  SWARM.join apikey: "#{config.consumer_key}", swarms: "#{config.swarms}", callback: (message) ->
    processMessage(message)

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
