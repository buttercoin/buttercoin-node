should = require('should')
OAuth2Authorizer = require('../lib/auth/oauth2')
RequestBuilder = require('../lib/request_builder')

describe 'Buttercoin OAuth2 authorizer', ->
  it 'should export a single class', ->
    OAuth2Authorizer.should.be.type 'function'
    OAuth2Authorizer.name.should.equal 'OAuth2Authorizer'

  testTokenProvider = (userId) ->
    if userId is 'test-user-id'
      'test-bearer-token'
    else
      null

  describe 'initialization', ->
    it 'should have a tokenProvider', ->
      auth = new OAuth2Authorizer(testTokenProvider)
      auth.tokenProvider.should.equal testTokenProvider

  describe 'authenticated requests', ->
    builder = new RequestBuilder()

    it 'should add a bearer header to an authenticated request', ->
      auth = new OAuth2Authorizer(testTokenProvider, 'test-user-id')
      req = auth.authorize(_auth: true)
      req.headers.Authorization.should.equal 'Bearer test-bearer-token'

    it 'should throw an error if no bearer token is available', ->
      auth = new OAuth2Authorizer(testTokenProvider, 'fake-user-id')
      (-> auth.authorize(_auth: true)).should.throw("No credentials for evidence: fake-user-id")

    it 'should not add a bearer header to an unauthenticated request', ->
      auth = new OAuth2Authorizer(testTokenProvider, 'test-user-id')
      req = auth.authorize(_auth: false)
      should.not.exist(req.headers?.Authorization)




