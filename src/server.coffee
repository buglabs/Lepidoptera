#### Lepidoptera
#
# **Lepidoptera** is an example solution built on top of [Swarm](http://github.com/buglabs/swarm).
#
# It is a visualization of fleet movement that can help to quickly
# identify and answer high level questions like
#
#    * how many people are sleeping?
#    * which drivers are the most efficient?
#    * are there any areas that are more difficult to get to?
#
#    etc...

#### Installation
#
# Lepidoptera requires [Node.js](http://nodejs.org/) (`brew install node`)
# and [npm](http://npmjs.org) (`curl http://npmjs.org/install.sh | sh`) for
# installation. To install the dependencies once npm is available:
#
#     npm install
#     npm install supervisor -g
#     supervisor src/*coffee


#### Usage
#
# Browse [http://localhost/locations](http://localhost/locations) to witness the magic
#
# You will also want to look at [Faker](faker.html) which can create said magic

express = require 'express'
app = express.createServer()
jade = require 'jade'
config = JSON.parse require('fs').readFileSync './config.json', 'utf8'

#### Routing
#
# To see a map of all the location feeds, GET `/locations`

app.get '/locations', (req, res) ->
  console.log 'setting up keepalive connection'
  res.writeHead 200, "Content-Type": "text/html"
  setInterval ( -> res.write '\n'), 30000

  options = locals: { config: config }

  jade.renderFile 'src/map.jade', options, (error, html) ->
    console.log 'rendering jade'

    if error
      console.error '  ' + error
    else
      res.write html

app.use express.static(__dirname + '/public')
app.use app.router
app.listen 80
