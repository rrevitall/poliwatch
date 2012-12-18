onelog      = require 'onelog'
onelog.use onelog.Log4js
logger = require('onelog').get 'Logger'

SITE_SECRET = 'yeah whatever'

# Vendor dependencies.
_           = require 'underscore'
path        = require 'path'
Q           = require 'q'
cons        = require 'consolidate'
express     = require 'express'
sio         = require 'socket.io'
request     = require 'request'
RedisStore  = require('connect-redis')(express)
colors      = require 'colors'
Assets      = require 'live-assets'
Resource    = require 'express-resource'
passport    = require 'passport'
flash       = require 'connect-flash'

# App dependencies.
routes      = require './routes'
{Model}     = require './model'
{Routes}    = require './routes'
config      = require('./config')()

# Init db layer
# -------------
logger.info "Connecting to MongoDB at", config.mongo.url
model = new Model mongoUri: config.mongo.url

AuthController = require './auth'
authController = new AuthController

# Create app
app = express()
app.set 'port', config.app.port

# Live-Assets
# -----------
assets = new Assets
  paths: [
    'assets/app/js'
    'assets/app/css'
    'assets/vendor/js'
    'assets/vendor/css'
  ]
  digest: false
  expandTags: true
  assetServePath: '/assets/'
  remoteAssetsDir: '/'
  usePrecompiledAssets: false
  root: process.cwd()
  # Add more files to this array when you need to require them from a template.
  files: ['application.js', 'style.css']

# Precompile on every request.
app.use (req, res, next) ->
  env = assets.getEnvironment()
  assets.precompileForDevelopment (err) =>
    next()

assets.middleware app

app.engine 'jade', cons['jade']

# Session Store
# -------------
redis = require('redis-url').connect config.redis.url
sessionStore = new RedisStore client: redis

# Express Configuration
# ---------------------
app.configure ->
  app.set "views", process.cwd() + "/views"
  app.set "view engine", "jade"
  app.use express.favicon()
  app.use express.bodyParser()
  app.use express.static process.cwd() + "/public"
  app.use express.cookieParser()
  app.use express.session
    secret: SITE_SECRET
    store: sessionStore
    key: 'express.sid'
  app.use express.methodOverride()
  app.use flash()
  authController.setupMiddleware app
  app.use app.router

app.configure "development", ->
  app.use express.errorHandler(
    dumpExceptions: true
    showStack: true
  )
  app.use express.logger()

app.configure "production", ->
  app.use express.errorHandler()

# Routes
# ------
routes = new Routes
app.get "/", routes.index
app.get "/app", routes.app
authController.setupRoutes app

# Locals
# ------

# TODO: Change me.
app.locals title: 'Express Bootstrap'

# Start web server
# ----------------
server = require('http').createServer app
server.listen app.get('port')
logger.info "Express server listening on port #{app.get('port').toString().green.bold} in #{app.get('env')} mode"

# Socket.io
# ---------
io = sio.listen server
io.set 'log level', 1
io.set 'authorization', (data, accept) ->
  if data.headers.cookie
    data.cookie = require('connect').utils.parseCookie data.headers.cookie
    data.sessionID = data.cookie['express.sid']
    sessionStore.get data.sessionID, (err, session) ->
      if err or not session
        accept 'Error', false
      else
        data.session = session
        accept null, true
  else
    return accept 'No cookie transmitted', false

io.sockets.on 'connection', (socket) ->
  hs = socket.handshake
  socket.on 'hello', ->
    socket.emit 'hi'
