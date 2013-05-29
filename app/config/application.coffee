{Live} = require 'live'
config = require('config')()
path = require 'path'

class @App extends Live.Application

  configure: ->
    @enable Live.DefaultLibraries

    # Choose Mongoose or Sequelize
    @enable Live.Mongoose
    #@enable Live.Sequelize

    # Live Assets
    assets = @enable Live.Assets, ->
      @env.appendPath path.join process.cwd(), 'node_modules/flat-ui-pro/lib'
      @env.appendPath path.join process.cwd(), 'node_modules/op-tools'
      @env.registerEngine '.ts', require('helpers/TypeScriptEngine')
      @opts.files.push 'style-less.css'

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
      SocketsManager = require 'live/sockets/socketsManager'
      new SocketsManager server, @sessionStore,
        onConnection: (socket) ->
          SocketsConnection = require 'sockets/socketsConnection'
          new SocketsConnection socket
    @app.locals title: config.appPrettyName

    @app
