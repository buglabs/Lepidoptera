window.initialize = ->
  console.log "config: #{JSON.stringify config}"

  mapOptions = zoom: 12, center: new google.maps.LatLng(40.72498216901785, -73.99708271026611) , mapTypeId: google.maps.MapTypeId.ROADMAP
  mapCanvas = document.getElementById "map_canvas"
  mapGoogle = new google.maps.Map mapCanvas, mapOptions
  feed = 'location'

  markers = []

  SWARM.join apikey: "#{config.consumer_key}", swarms: config.swarms, callback: (message) ->

    #console.log "message: #{message}"
    if message.message?.body?.data?
      resource = message.message.from?.split('/')[1]
      updateResource resource, JSON.parse message.message.body.data

    if message.presence?.type?
      #console.log "message.presence: #{JSON.stringify message.presence}"
      swarm = message.presence.from?.split('@')[0]
      resource = message.presence.from?.split('/')[1]
      alive = message.presence.type is 'available'
      if message.presence.from.indexOf('web') is -1
        updatePresence swarm, resource, alive

  updatePresence = (swarm, resource, alive) ->
    #console.log "updatePresence(#{swarm}, #{resource}, #{alive})"

    # add the elements to the dom if not found
    dom_resource = $("#resources > ##{resource}")[0] \
      || $("#resources").append "<li id=#{resource}><a href=#>#{resource}</a><ul class='acitem'></ul></li>"

    # FIXME: better handling of feed class
    dom_feed = $("##{resource} > .acitem > .#{feed}")[0] \
      || $("##{resource} > .acitem").append "<li class='feed #{feed}'><a href=#>MPG: </a></li>"

    dom_resource.toggleClass 'alive', alive
    dom_feed.toggleClass 'alive', alive

  updateResource = (resource, data) ->
    #console.log "updateResource(#{resource}, #{data.mpg})"
    # FIXME: make dynamic
    $("##{resource} > .acitem > .#{feed} > a").replaceWith "<a href=#>MPG: #{JSON.stringify data.mpg}</a>"

    marker = new google.maps.Marker
      position: new google.maps.LatLng data.latitude, data.longitude
      icon: "http://robohash.org/#{resource}.png?size=40x40&set=set3"
      map: mapGoogle
      html: "<strong>#{resource}</strong>"
      title: resource

    infowindow = new google.maps.InfoWindow { content: resource }

    google.maps.event.addListener marker, 'click', () ->
      infowindow.setContent this.html
      infowindow.open mapGoogle, this

    markers.push marker
