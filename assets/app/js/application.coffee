#= require underscore/underscore
#= require backbone/backbone
#= require jade-runtime
#= require_tree ../templates
#= require backbone.marionette/lib/backbone.marionette
#= require backbone-pageable
#= require ./test
#= require jquery-timeago/jquery.timeago
#= require moment/moment
#= require sugar/release/sugar-full.development

# Workaround jade-runtime's use of `require`.
require = -> readFileSync: -> ''

# Convenience.
window.BM = Backbone.Marionette
window.B = Backbone

jQuery.extend
  percentage: (a) -> Math.round(a * 100).toFixed(0) + '%'

window.App = new BM.Application
App.addInitializer (opts) ->

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
    routers: {}
    title: 'Poliwatch'

  $('body').on 'click', 'a', (e) ->
    app.routers.router.navigate $(this).attr('href'), trigger: true
    return false

  # Initialize views.
  app.views.main = main = new MainLayout
  app.views.nav = nav = new NavView
  app.views.footer = footer = new FooterView
  main.render()
  main.nav.show nav
  main.footer.show footer

  # Start router.
  app.routers.router = new Router
  B.history.start pushState: true, root: '/app/'

$(document).ready ->
  App.start()

class Router extends B.Router

  routes:
    'home': ''
    'divisions': 'divisions'
    'division/:id': 'division'
    'mps': 'mps'
    'senators': 'senators'
    'policies': 'policies'

  home: =>
    console.log 'home'

  divisions: =>
    page = new DivisionsPage
    app.views.main.content.show page

  division: (id) =>
    model = new DivisionModel id: id
    page = new DivisionPage model: model
    model.on 'sync', ->
      app.views.main.content.show page
    model.fetch()

  mps: =>

  senators: =>

  policies: =>

class NavView extends BM.ItemView
  template: JST['main/nav']

class FooterView extends BM.ItemView
  template: JST['main/footer']

class DivisionsPage extends BM.Layout
  template: JST['divisions']
  regions:
    content: '.content'
  onRender: =>
    coll = app.collections.divisions = new DivisionsCollection
    view = new DivisionsCollectionView collection: coll
    @content.show view
    coll.fetch()

class DivisionPage extends BM.ItemView
  template: JST['division']
  modelEvents:
    change: 'render'

  serializeData: =>
    model = @model.toJSON() or {}
    console.log model
    #model.json.speeches = _.map model.json.speeches, (x) ->
    #  console.log x
    #  x.speakerImage = "http://parlinfo.aph.gov.au/parlInfo/download/handbook/allmps/#{x.mpid}/upload_ref_binary/#{x.mpid}.jpg"
    #  x
    model

class MainLayout extends BM.Layout
  el: '#main'
  template: JST['main']
  regions:
    nav: '#nav'
    content: '#content'
    footer: '#footer'

class DivisionModel extends B.Model
  urlRoot: '/divisions'

class DivisionsCollection extends B.PageableCollection
  model: DivisionModel
  url: '/divisions'
  mode: 'infinite'
  state:
    firstPage: 1
    currentPage: 1
    pageSize: 5

  queryParams:
    currentPage: 'page'
    pageSize: 'pageSize'

class DivisionRowView extends BM.CompositeView
  template: JST['divisions/row']
  onRender: =>
    @setElement @$el.children()
    @$('abbr').timeago()
  serializeData: =>
    _.extend @model.toJSON(),
      date: new Date @model.get('date')
      time: new Date @model.get('time')

class DivisionsCollectionView extends BM.CompositeView
  template: JST['divisions/table']
  itemView: DivisionRowView
  itemViewContainer: 'tbody'
  ui:
    next: 'next'
    prev: 'prev'

