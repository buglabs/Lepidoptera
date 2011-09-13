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
# Make sure the configuration in `config.json` is correct, then browse
# [http://localhost/locations](http://localhost/locations) to witness the magic
#
# You will also want to look at [Faker](faker.html) which can create said magic

@app = require('zappa') ->
  gzippo = require 'gzippo'

  configure ->
    set 'view engine': 'jade'
    set 'view options': { layout: false }
    app.register '.jade', zappa.adapter 'jade'
    use app.router, gzippo.staticGzip __dirname + '/public'

  get '/locations': ->
    @config = JSON.parse require('fs').readFileSync './config.json', 'utf8'
    render 'map'
