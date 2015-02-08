should = require('should')

Buttercoin = require('../lib/client')
RequestBuilder = require('../lib/request_builder')
Order = require('../lib/requests/create_order')
Q = require('q')

class NoopAuthorizer
  authorize: (request) ->
    @lastRequest = request
    request

class NoopHandler
  do: (request, opts) =>
    Q(@mockResponse)

Buttercoin.testClient = () ->
  new Buttercoin(
    new RequestBuilder(),
    new NoopAuthorizer(),
    new NoopHandler())

describe 'Buttercoin client', ->
  describe 'constructor methods', ->
    it 'should construct an OAuth2 client', ->
      testProvider = (name) -> 'fillmore' if name is 'millard'

      clientFactory = Buttercoin.withOAuth2(testProvider)

      client = clientFactory.as('millard')
      client.should.be.an.instanceOf Buttercoin
      client.auth.constructor.name.should.equal 'OAuth2Authorizer'
      client.auth.tokenProvider.should.equal testProvider
      client.handler.do.should.be.type 'function'

    it 'should construct an API key client', ->
      k = 'abcdefghijklmnopqrstuvwxyz123456'
      s = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
      client = Buttercoin.withKeySecret(k, s)
      client.should.be.an.instanceOf Buttercoin
      client.auth.constructor.name.should.equal 'KeySecretAuthorizer'
      client.auth.key.should.equal k
      client.auth.secret.should.equal s
      client.handler.do.should.be.type 'function'

  describe 'operations', ->
    client = Buttercoin.testClient()

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

    describe 'Orders', ->
      it 'should support posting an order', (done) ->
        client.handler.mockResponse =
          result:
            statusCode: 202
            headers: {location: 'https://sandbox.buttercoin.com/v1/orders/testOrderId' }

        res = client.postOrder(Order.marketBid(100))
        req = client.auth.lastRequest
        req.method.should.equal 'POST'
        req.url.should.equal 'https://sandbox.buttercoin.com/v1/orders'
        req._auth.should.equal true
        JSON.stringify(req.body).should.equal '{"instrument":"USD_BTC","side":"sell","orderType":"market","quantity":100}'

        res.then (orderInfo) ->
          orderInfo.url.should.equal 'https://sandbox.buttercoin.com/v1/orders/testOrderId'
          orderInfo.orderId.should.equal 'testOrderId'
          done()
        .done

      it 'should be able to query orders', (done) ->
        client.handler.mockResponse =
          result:
            statusCode: 200
            body: JSON.stringify(
              results: [{
                side: 'buy', quantity: 1, priceCurrency: 'USD', price: 10,
                orderId: 'b1b520ba-caf1-4e54-a914-e8fb0ed6e6e3',
                quantityCurrency: 'BTC', status: 'opened', orderType: 'limit',
                events: [
                  {eventType: 'opened', eventDate: '2015-02-07T07:32:55.025Z', quantity: 1},
                  {eventType: 'created', eventDate: '2015-02-07T07:32:55.021Z'}
                ]}])

        res = client.getOrders({})
        req = client.auth.lastRequest
        req.method.should.equal 'GET'
        req.url.should.equal 'https://sandbox.buttercoin.com/v1/orders'
        req._auth.should.equal true

        res.then (results) ->
          should.not.exist(results.statusCode)
          results.length.should.equal 1
          done()

      it 'should be able to cancel an order', (done) ->
        client.handler.mockResponse =
          result:
            statusCode: 204
            body: ''

        res = client.cancelOrder('test-order-id')
        req = client.auth.lastRequest
        req.method.should.equal 'DELETE'
        req.url.should.equal 'https://sandbox.buttercoin.com/v1/orders/test-order-id'
        req._auth.should.equal true

        res.then (result) ->
          should.exist(result)
          result.should.equal "OK"
          done()

