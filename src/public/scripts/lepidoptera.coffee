#### Lepidoptera
#
# **Lepidoptera** is an example solution built on top of [Swarm](http://github.com/buglabs/swarm)
# This is the main message handler, which uses the DOM as the db, and jQuery as the ORM :-p
#

lepidoptera = ->
  # this config should be passed through using jade
  console.log "config: #{JSON.stringify config}"

  # creating the google map
  mapOptions = zoom: 12, center: new google.maps.LatLng(40.72498216901785, -73.99708271026611) , mapTypeId: google.maps.MapTypeId.ROADMAP
  mapCanvas = document.getElementById "map_canvas"
  mapGoogle = new google.maps.Map mapCanvas, mapOptions
  feed = 'location'
  resource = null

  markers = []
  cars = [ { name: "fiesta", count: 0 }, { name: "fusion", count: 0 } ]

  # the javascript api handles message callbacks as a consumer only
  SWARM.join apikey: "#{config.consumer_key}", swarms: config.swarms, callback: (message) ->

    # for _messages_, update the mpg readout
    if resource and message.message?.body?
      updateFeed resource, message.message.body

    # for _presence_, determine if a resource just joined or just left
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
      dom_feed = $("##{resource} > .feeds").append(
        "<li class='feed #{feed}'><a href=#>#{feed}</a>:<span class='data'></span></li>"
      )

    # replace the inner html with the new mpg data
    dom_feed.find(".data").html "#{data[feed]}"

    # see if we have a marker on the map for this resource
    for m in markers
      marker = m if m.title is resource

    # if we don't, add it to the map. This may be better put in updatePresence
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

    # now that we have the correct marker, update its location
    marker.setPosition new google.maps.LatLng data.latitude, data.longitude

lepidoptera()
