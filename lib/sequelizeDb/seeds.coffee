Faker = require 'Faker'
uuid = require 'node-uuid'
bcrypt  = require 'bcrypt'

# Seed database with users.
@run = (models, done) ->

  generatePasswordHash = (password) ->
    salt = bcrypt.genSaltSync 10
    hash = bcrypt.hashSync password, salt
    [hash, salt]

  # Create test user.
  [hash, salt] = generatePasswordHash 'test'
  models.User.create
    name: 'Test'
    email: 'test@test.com'
    password: hash
    salt: salt

  #for i in [0..10]
  #  models.User.create
  #    name: Faker.Name.findName()
