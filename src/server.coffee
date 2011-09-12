#### Lepidoptera
#
# **Lepidoptera** is an example solution built on top of [Swarm](http://github.com/buglabs/swarm)
# This is the server component, which allows for viewing a fleet a vehicles
#

#### Installation
#
# Lepidoptera requires [Node.js](http://nodejs.org/) (`brew install node`)
# and [npm](http://npmjs.org) (`curl http://npmjs.org/install.sh | sh`)
# Once npm is available,
#
#     npm install
#     npm start

#### Usage
#
# Browse [http://localhost/locations](http://localhost/locations) to witness the magic
#
# You will also want to look at [Faker](faker.html) which can create said magic

express = require 'express'
gzippo = require 'gzippo'
app = express.createServer()

#### Configuration
#
# The config file is config.json, which is shared between server and faker
#
config = JSON.parse require('fs').readFileSync './config.json', 'utf8'

app.set 'view engine', 'jade'
app.set 'view options', { layout: false }

#### Routing
#
# To see a map of all the location feeds, GET `/locations`
#
app.get '/locations', (req, res) ->
  res.render 'map', locals: { config: config }

app.use gzippo.staticGzip(__dirname + '/public')
app.use app.router
app.listen process.env.npm_package_config_port or 8080
