should = require('should')
ButtercoinOAuth2Client = require('../lib/oauth2_client')

describe 'Buttercoin OAuth2 client', ->
  it 'should export a single class', ->
    ButtercoinOAuth2Client.should.be.type 'function'
    ButtercoinOAuth2Client.name.should.equal 'ButtercoinOAuth2Client'

  describe 'initialization', ->

  describe 'request building', ->
