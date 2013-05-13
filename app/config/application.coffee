{Live} = require 'framework'
config = require('config')()

class @App extends Live.Application

  configure: ->
    @enable Live.DefaultLibraries

    # Choose Mongoose or Sequelize
    @enable Live.Mongoose
    #@enable Live.Sequelize

    # Live Assets
    assets = @enable Live.Assets, ->
      # Enable if using Flat UI from designmodo.
      # Free.
      #env.appendPath path.join process.cwd(), 'node_modules/Flat-UI'
      # Pro.
      #env.appendPath path.join process.cwd(), 'node_modules/flat-ui-pro'

    # Connect logging
    # ---------------
    # Should be after asset serving unless we want to log asset requests.
    onelog = require 'onelog'
    log4js = onelog.getLibrary()
    connectLogger = require('onelog').get 'connect'
    @use log4js.connectLogger connectLogger, level: log4js.levels.INFO, format: ':method :url'
    # ---

    @enable Live.RedisSession
    @enable Live.JadeTemplating
    #@enable Live.CoffeecupTemplating
    @enable Live.StandardPipeline
    @enable Live.PassportAuth.Middleware
    @enable Live.StandardRouter
    @enable Live.ErrorHandling
    @enable require './routes'
    @enable Live.PassportAuth.Routes

    @app.on 'server:listening', (server) =>
      SocketsManager = require 'framework/sockets/socketsManager'
      new SocketsManager server, @sessionStore,
        onConnection: (socket) ->
          SocketsConnection = require 'sockets/socketsConnection'
          new SocketsConnection socket
    @app.locals title: config.appPrettyName

    @app
