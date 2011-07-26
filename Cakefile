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
