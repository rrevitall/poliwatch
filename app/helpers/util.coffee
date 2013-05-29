_ = require 'underscore'

class @SequelizeUtils

  @getAllSequelizeModels: (Model) ->
    _.map Model.sequelize.daoFactoryManager.all, (model) ->
      obj = {}; obj[model.name] = model.rawAttributes; obj

class @Util

  @parse: (input, props) ->
    return null unless input?
    unless _.isArray props then props = [props]

    fn = (model) ->
      model = model.toJSON()
      for prop in props
        model[prop] = JSON.parse model[prop]
      model

    if _.isArray input
      _.map input, fn
    else
      fn input
