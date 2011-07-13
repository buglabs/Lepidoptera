app = require('express').createServer()
jade = require 'jade'
request = require 'request'
DNode = require 'dnode'

swarm.id     = '37262a64817a13bd03bba603546f379aa33b3812'
swarm.key    = '47845a166702ec7e5dfcf10f0d83b9a9e93f26fa'
swarm.server = 'api.bugswarm-test'

# put /location/bugName with latitude and longitude in the request object
app.put '/location/:bug', (req,res) ->
  sendLocation req.params.bug, req.latitude, req.longitude

# get /location/bugName/latitude/longitude works too
app.get '/location/:bug/:latitude,:longitude', (req, res) ->
  sendLocation req.params.bug, req.params.latitude, req.params.longitude

# get /locations will show an updating map
app.get '/locations', watchMap

# sendLocation pushes out a new location for any bug
sendLocation = (bugName, latitude, longitude) ->
  request.put
    header: 'X-BugSwarmApiKey: #{swarm.key}'
    url:    'http://#{swarm.server}/resources/#{bugName}/feeds/location?swarm_id=#{swarm.id}'
    json:   JSON.stringify { latitude: latitude, longitude: longitude }
    (error, response, body) ->

      if not error and response.statusCode == 200
        console.log 'sent #{latitude}, #{longitude} for #{bug}'

# watchMap will only display new markers since the page was opened
watchMap = (req, res) ->
  console.log 'creating temporary consumer'

  consumer = nil
  request
    url:'http://#{swarm_server}/#{swarm.key}/#{swarm.id}/resources'
    json: JSON.stringify { action: 'add', resource_type: 'consumer' }
    (error, response, body) ->
      if error or response.statusCode == 200
        console.err 'error creating temporary consumer'
      else
        consumer = body.resource_id

        console.log 'setting up keepalive connection'
        response.writeHead 200, "Content-Type": "text/html"
        setInterval (() -> res.write '\n'), 30000


        console.log 'rendering map.jade'
        # note that the dnode server is started here
        jade.renderFile 'map.jade', (err, html) ->
          not err and res.write html


        console.log 'requesting feed'
        request
          url: 'http://#{swarm.server}/#{swarm.key}/#{swarm.id}/feeds?stream=true', (error, response, body) ->
          if not error and response.statusCode == 200
            response.on 'data', (data) ->
              console.log 'calling remote.addNewLocation on data' + data
              client = DNode.connect 6060, (remote) ->
                remote.addNewLocation data
      

            response.on 'close', (data) ->
              console.log 'removing temporary consumer ' + consumer
              request
                url: 'http://#{swarm.server}/#{swarm.key}/#{swarm.id}/resources'
                json: JSON.stringify { action: 'remove', resource_id: consumer }
                ( error, response, body) ->
                  if error or response.statusCode == 200
                    console.err 'error removing temporary consumer'

app.listen 3000
