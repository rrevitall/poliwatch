#= require underscore/underscore
#= require backbone/backbone
#= require jade-runtime
#= require_tree ../templates

# Workaround jade-runtime's use of `require`.
require = -> readFileSync: -> ''

# Convenience.
window.BM = Backbone.Marionette
window.B = Backbone

$(document).ready ->
  # Client-side template functions are accessible as follows:
  # `JST['templates/home']()`

  # Enable Socket.IO.
  window.socket = io.connect()
  socket.on 'msg', (msg) ->
    console.log 'Received socket.io message', msg
  # Send a test message to server on connection.
  socket.on 'connect', ->
    socket.emit 'hello', 'Hello, World!'

  window.app =
    collections: {}
    models: {}
    views: {}
    mixins: {}

  router = new Router
  B.history.start pushState: true, root: '/app/'

  $('body').on 'click', 'a', (e) ->
    router.navigate $(this).attr('href'), trigger: true
    return false

class Router extends B.Router

  routes:
    '': 'home'

  home: =>
    console.log 'You are home!'
