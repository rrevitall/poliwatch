config = require('./index')()
{Live} = require 'framework'

class @App extends Live.Application

  configure: ->
    @enable Live.DefaultLogging
    logger = require('onelog').get 'LiveFramework'
    @enable Live.DefaultLibraries
    @enable Live.Mongoose
    @enable Live.Assets
    @enable Live.RedisSession
    @enable Live.JadeTemplating
    @enable Live.StandardPipeline
    @enable Live.PassportAuth.Middleware
    @enable Live.StandardRouter
    @enable Live.ErrorHandling
    @enable require './routes'
    @enable Live.PassportAuth.Routes
    @app.locals title: config.appPrettyName
    @app
