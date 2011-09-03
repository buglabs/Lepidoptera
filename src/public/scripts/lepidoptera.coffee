lepidoptera = ->
  console.log "config: #{JSON.stringify config}"

  mapOptions = zoom: 12, center: new google.maps.LatLng(40.72498216901785, -73.99708271026611) , mapTypeId: google.maps.MapTypeId.ROADMAP
  mapCanvas = document.getElementById "map_canvas"
  mapGoogle = new google.maps.Map mapCanvas, mapOptions
  feed = 'location'
  resource = null

  markers = []
  cars = [ { name: "fiesta", count: 0 }, { name: "fusion", count: 0 } ]

  SWARM.join apikey: "#{config.consumer_key}", swarms: config.swarms, callback: (message) ->
    if resource and message.message?.body?
      updateFeed resource, message.message.body

    if message.presence?.type?
      swarm = message.presence.from?.split('@')[0]
      alive = message.presence.type is 'available'
      if message.presence.from.indexOf('web') is -1
        car = cars[Math.floor(Math.random() * cars.length)]
        resource = car.name + "_#{car.count++}"
        updatePresence swarm, resource, alive

  updatePresence = (swarm, resource, alive) ->
    # if the resource doesn't exist, add it
    dom_resource = $("#resources > ##{resource}")[0] \
      or $("#resources").append(
        "<li id='#{resource}'><a href=#>#{resource}</a><ul class='feeds'></ul></li>"
      )

    dom_resource.find("##{resource}").toggleClass 'alive', alive

  updateFeed = (resource, body) ->
    feed = body.feed
    data = JSON.parse body.data

    console.log "updateFeed(#{resource},#{feed},#{JSON.stringify data})"

    # if the feed doesn't exist, add it
    dom_feed = $("##{resource} > .feeds > .#{feed}")

    if dom_feed.length is 0
      $("##{resource} > .feeds").append(
        "<li class='feed #{feed}'><a href=#>#{feed}</a></li>"
      )

    dom_feed.find("a").html "#{feed}: #{data[feed]}"

    for m in markers
      marker = m if m.title is resource

    if not marker?
      marker = new google.maps.Marker
        position: new google.maps.LatLng data.latitude, data.longitude
        icon: "http://robohash.org/#{resource}.png?size=40x40&set=set3"
        map: mapGoogle
        html: "<strong>#{resource}</strong>"
        title: resource
      infowindow = new google.maps.InfoWindow

      google.maps.event.addListener marker, 'click', () ->
        infowindow.setContent this.html
        infowindow.open mapGoogle, this

    markers.push marker

    marker.setPosition new google.maps.LatLng data.latitude, data.longitude

lepidoptera()
