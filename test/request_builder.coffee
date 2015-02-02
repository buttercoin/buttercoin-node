should = require('should')
RequestBuilder = require('../lib/request_builder')
Endpoint = require('../lib/endpoint')

describe 'RequestBuilder', ->
  builder = new RequestBuilder()

  it 'should be exported as a single class', ->
    RequestBuilder.should.be.type 'function'
    RequestBuilder.name.should.equal 'RequestBuilder'

  describe 'initialization', ->
    it 'should default to version 1 and sandbox', ->
      builder.version.should.equal('v1')
      builder.endpoint.should.equal(Endpoint.defaults.sandbox)

  describe 'requests', ->
    it 'should be able to build a request based on endpoint', ->
      req = builder.buildRequest('GET', 'some/api/path')
      req.method.should.equal 'GET'
      req.url.should.equal 'https://www-sandbox.buttercoin.com/v1/some/api/path'
      req.strictSSL.should.equal true

      localEndpoint = new Endpoint(protocol: 'http', port: 9003, host: 'localhost')
      localBuilder = new RequestBuilder(localEndpoint, 'v2')
      req = localBuilder.buildRequest('POST', 'do/a/thing')
      req.method.should.equal 'POST'
      req.url.should.equal 'http://localhost:9003/v2/do/a/thing'
      req.strictSSL.should.equal false

    it 'should support GET /account/balances', ->
      req = builder.getBalances()
      req.url.should.equal 'https://www-sandbox.buttercoin.com/v1/account/balances'

    it 'should support POST /orders', ->
      req = builder.createOrder({})
      req.method.should.equal 'POST'
      req.url.should.equal 'https://www-sandbox.buttercoin.com/v1/orders'
      JSON.stringify(req.body).should.equal "{}"

