_ = require 'underscore'

module.exports = (env) ->

  appName = "expressbootstrap"

  envs =
    development:
      app:
        port: 3030
        url: "http://localhost.#{appName}.herokuapp.com:3030"
      mongo:
        url: "mongodb://localhost/#{appName}" # TODO
      redis:
        url: "localhost"
    production:
      app:
        port: process.env.PORT
        url: "http://#{appName}.herokuapp.com"
      mongo:
        url: process.env.MONGOLAB_URI or process.env.MONGOHQ_URL
      redis:
        url: process.env.REDISTOGO_URL
    common:
      fb:
        appId: '451899438203860' # TODO
        appSecret: '0a05a69a5d56da18ee2a1ffd9f53ecda' # TODO

  unless env?
    env = process.env.NODE_ENV or 'development'
  config = _.clone envs.common
  _.extend config, _.clone envs[env]
  return config
