logger = require('onelog').get 'Model'
mongoose = require 'mongoose'
config = require('./config')()
bcrypt = require 'bcrypt'

Schema = mongoose.Schema

class Model

  constructor: ->

    UserSchema = new Schema
      name: String
      email: String
      password: String
      salt: String
      fb: Schema.Types.Mixed

    UserSchema.methods.validatePassword = (attempt, cb) ->
      hashedAttempt = bcrypt.hashSync attempt, @salt
      cb null, @password is hashedAttempt

    UserSchema.statics.findOrCreate = (profile, cb) ->
      @findOne {'fb.id': profile.id}, (err, user) =>
        return cb err if err
        return cb(null, user) if user
        @create {name: profile.displayName, fb: profile}, (err, user) =>
          if err
            logger.error "Registration failed:", err
            return cb err if err
          logger.debug "Registration succeeded:", user
          cb null, user

    @User = mongoose.model 'User', UserSchema

    mongoose.set 'debug', true
    mongoose.connect config.mongo.url
    mongoose.connection.on 'error', (err) ->
      logger.error "Connection error: " + err
    mongoose.connection.on 'open', ->
      logger.info "Connected!"

exports.Model = Model
