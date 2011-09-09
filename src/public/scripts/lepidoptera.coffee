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

  markers = []

  # the javascript api handles message callbacks as a consumer only
  SWARM.join apikey: "#{config.consumer_key}", swarms: config.swarms, callback: (message) ->
    from = message.presence?.from or message.message?.from
    resource_id = from?.split('/')[1]

    if resource_id?.indexOf('web') is -1
      if resource_id?.indexOf('browser') is -1
        # for _messages_, update the readout
        if message.message?.body?
          if JSON.parse(message.message.body.data).presence is 'unavailable'
            $("##{resource_id}").toggleClass 'alive', false
          else
            try
              updateFeed resource_id, message.message.body
            catch err
              console.error "#{message.message.body}"

        # for _presence_, determine if a resource just joined or just left
        if message.presence?.type?
          updatePresence resource_id, message.presence.type is 'available'

  updatePresence = (resource_id, alive) ->
    console.log "updatePresence(#{resource_id}, #{alive})"
    # if the resource doesn't exist, add it
    dom_resource = $("#resources > ##{resource_id}")

    if alive and not dom_resource[0]?
      dom_resource = $("#resources").append("<li class='resource alive' id='#{resource_id}'><h1 class='car_icon_wrapper'><span class='car_icon'>Car Icon</span></h1><span class='car_name'></span><ul class='feeds'></ul></li>")

  updateFeed = (resource_id, body) ->
    feed = body.feed
    data = JSON.parse body.data

    console.log "updateFeed(#{resource_id},#{feed},#{JSON.stringify data})"

    dom_name = $("##{resource_id} > .car_name")
    dom_name.html(data.car_name) if dom_name[0]?

    # if the feed doesn't exist, add it
    dom_feed = $("##{resource_id} > .feeds > .#{feed}")

    if dom_feed.length is 0 and data[feed]?
      dom_feed = $("##{resource_id} > .feeds").append("<li class='feed #{feed}'><h1 class='icon_wrapper'><span class='label'>#{feed}</span></h1>:<span class='data'></span></li>")

    # replace the inner html with the new mpg data
    dom_feed.find(".data").html "#{data[feed]}"

    # see if we have a marker on the map for this resource
    for m in markers
      marker = m if m.title is data.car_name

    # if we don't, add it to the map. This may be better put in updatePresence
    if not marker?
      marker = new google.maps.Marker
        position: new google.maps.LatLng data.latitude, data.longitude
        icon: "../images/icon-car-map-active.png"
        map: mapGoogle
        html: "<strong>#{data.car_name}</strong>"
        title: data.car_name
      infowindow = new google.maps.InfoWindow

      google.maps.event.addListener marker, 'click', () ->
        infowindow.setContent this.html
        infowindow.open mapGoogle, this

    markers.push marker

    # now that we have the correct marker, update its location
    marker.setPosition new google.maps.LatLng data.latitude, data.longitude

lepidoptera()
