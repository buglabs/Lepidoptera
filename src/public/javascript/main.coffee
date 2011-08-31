window.initialize = ->
  console.log "config: #{JSON.stringify config}"

  console.log 'creating map centered around BUG Labs'
  mapOptions = zoom: 12, center: new google.maps.LatLng(40.72498216901785, -73.99708271026611) , mapTypeId: google.maps.MapTypeId.ROADMAP
  mapCanvas = document.getElementById "map_canvas"
  mapGoogle = new google.maps.Map mapCanvas, mapOptions

  markers = []

  SWARM.join apikey: "#{config.consumer_key}", swarms: config.swarms, callback: (message) ->
    console.log "message: #{JSON.stringify message}"
    if message.message?.body?.data?
      console.log "data: #{message.message.body.data}"
      updateResource JSON.parse message.message.body.data
    if message.presence?.type?
      console.log "presence: #{JSON.stringify message.presence}"
      updatePresence message.presence.from, message.presence.type

  updatePresence = (from, type) ->
    alive = type is 'available'
    swarm = from.split('@')[0]
    resource = from.split('/')[1]

    console.log "#{resource} is #{alive}!"

    # add the elements to the dom if not found and keep up to date
    dom_swarm = $ "##{swarm}" || $("#swarms").append "<ul id=#{swarm} class='swarm'><ul>"
    dom_resource = $ "##{swarm} > ##{resource}" || $("##{swarm}").append "<li id=#{resource}>#{resource} (#{data.mpg} mpg)</li>"

    dom_resource.attr class: (alive? 'alive': 'dead')

  updateResource = (location) ->
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
