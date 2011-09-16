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
# [http://localhost/](http://localhost/) to witness the magic
#
# You will also want to look at [Faker](faker.html) which can create said magic

zappa = require 'zappa'
config = JSON.parse require('fs').readFileSync 'config.json'

zappa 80, {config}, ->
  enable 'serve jquery'

  configure ->
    set 'view engine': 'jade'
    set 'view options': { layout: false }
    use app.router, 'static'

  app.register '.jade', zappa.adapter 'jade'#, blacklist


  get '/': ->
    @config = config
    render 'map'

zappa 33, {config}, ->
  def config: config
  requiring 'faker'

  get '/add': ->
    faker.add(config)

  get '/remove': ->
    faker.remove()
