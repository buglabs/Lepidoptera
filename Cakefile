{spawn, exec} = require 'child_process'
{log, error} = console; print = log

shell = (cmds, callback) ->
  cmds = [cmds] if Object::toString.apply(cmds) isnt '[object Array]'
  exec(cmds.join(' && '), (err, stdout, stderr) ->
    print trimStdout if trimStdout = stdout.trim()
    error stderr.trim() if err
    callback() if callback
  )

task 'docco', 'build the docs', ->
  shell 'docco src/*coffee'
  shell 'open docs/server.html'

task 'run', 'update the dependencies and run the application', ->
  shell 'npm up'
  shell 'sudo supervisor src/*coffee', (error, stdout, stderr) ->
    console.log "stdout: #{stdout}"
    console.log "stderr: #{stderr}"

  shell 'open http://localhost/locations'
