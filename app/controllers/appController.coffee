Model = require('op-tools/voting-record/aph/model')()
iced = require 'iced-coffee-script'
_ = require 'underscore'
{SequelizeUtils} = require 'helpers/util'

class AppController

  @index: (req, res) =>
    res.render 'index', shared: {}

  @app: (req, res) =>
    #unless req.user
    #  res.render 'login'
    #else

    # Expose all sequelize models client-side.
    models = SequelizeUtils.getAllSequelizeModels Model

    res.render 'app',
      shared: models: models
    #, user: req.user

module.exports = AppController
