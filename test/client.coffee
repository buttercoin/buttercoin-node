should = require('should')

Buttercoin = require('../lib/client')
RequestBuilder = require('../lib/request_builder')
Order = require('../lib/requests/create_order')

class NoopAuthorizer
  authorize: (request) ->
    @lastRequest = request
    request

class NoopHandler
  do: (request, opts) ->

Buttercoin::testClient = () ->
  new Buttercoin(
    new RequestBuilder(),
    new NoopAuthorizer(),
    new NoopHandler())

describe 'Buttercoin client', ->
  describe 'constructor methods', ->
    it 'should construct an OAuth2 client', ->
      testProvider = ->
      client = Buttercoin::withOAuth2(testProvider)
      client.should.be.an.instanceOf Buttercoin
      client.auth.constructor.name.should.equal 'OAuth2Authorizer'
      client.auth.tokenProvider.should.equal testProvider
      client.handler.do.should.be.type 'function'

    it 'should construct an API key client', ->
      k = 'abcdefghijklmnopqrstuvwxyz123456'
      s = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
      client = Buttercoin::withKeySecret(k, s)
      client.should.be.an.instanceOf Buttercoin
      client.auth.constructor.name.should.equal 'KeySecretAuthorizer'
      client.auth.key.should.equal k
      client.auth.secret.should.equal s
      client.handler.do.should.be.type 'function'

  describe 'operations', ->
    client = Buttercoin::testClient()

    it 'should support getting the order book', ->
      client.getOrderBook()
      req = client.auth.lastRequest
      req.method.should.equal 'GET'
      req.url.should.equal 'https://sandbox.buttercoin.com/v1/orderbook'
      req._auth.should.equal false

    it 'should support getting trade history', ->
      client.getTradeHistory()
      req = client.auth.lastRequest
      req.method.should.equal 'GET'
      req.url.should.equal 'https://sandbox.buttercoin.com/v1/trades'
      req._auth.should.equal false

    it 'should support getting the ticker', ->
      client.getTicker()
      req = client.auth.lastRequest
      req.method.should.equal 'GET'
      req.url.should.equal 'https://sandbox.buttercoin.com/v1/ticker'
      req._auth.should.equal false

    it 'should support getting account balances', ->
      client.getBalances()
      req = client.auth.lastRequest
      req.method.should.equal 'GET'
      req.url.should.equal 'https://sandbox.buttercoin.com/v1/account/balances'
      req._auth.should.equal true


    it 'should reject bad arguments when posting an order', ->
      (-> client.postOrder("foo")).should.throw('Invalid argument to createOrder: foo')

    it 'should support posting an order', ->
      client.postOrder(Order::marketBid(100))
      req = client.auth.lastRequest
      req.method.should.equal 'POST'
      req.url.should.equal 'https://sandbox.buttercoin.com/v1/orders'
      req._auth.should.equal true
      JSON.stringify(req.body).should.equal '{"instrument":"USD_BTC","side":"sell","orderType":"market","quantity":100}'

