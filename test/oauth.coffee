should = require('should')
OAuth = require('../lib/oauth')
Endpoint = require('../lib/endpoint')

describe "OAuth", ->
  it "should not be null or undefined", ->
    OAuth.should.not.equal null
    OAuth.should.not.equal undefined

  client = new OAuth()
  it "should produce a valid auth url", ->
    url = client.authUrl(Endpoint.defaults.production, 'test-id', 'http://example.com', 'test-scope', 'test-state')
    url.should.equal "https://api.buttercoin.com/oauth/auth?client_id=test-id&redirect_uri=http%3A%2F%2Fexample.com&scope=test-scope&state=test-state"
