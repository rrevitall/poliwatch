module.exports = (config) ->
  appName: 'expressbootstrap' # TODO
  appPrettyName: 'Express Bootstrap'
  port: 3030
  # TODO: Change this to the url where your site is hosted in production.
  #   See `environments/production` for usage.
  deployUrl: null

  # Which database is used for the User model.
  services:
    #user: 'sequelize'
    user: 'mongoose'
