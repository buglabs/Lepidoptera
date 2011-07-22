{exec} = require 'child_process'

task 'build', 'install the deps, run the server, open the documentation and apps', ->
  exec 'npm install'
  exec 'sudo npm install -g supervisor'
  exec 'docco server.coffee'
  exec 'supervisor -g server.coffee'

  console.log 'open docs/server.html'
  console.log 'open http://localhost/locations'
  return
