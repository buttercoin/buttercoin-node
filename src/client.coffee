RequestBuilder = require('./request_builder')
CreateOrder = require ('./requests/create_order')
request = require('request')
merge = require('merge')
Q = require('q')

UNEXPECTED_RESPONSE = 'Unexpected response format. You might be using the wrong version of the API, or this API Client is out of date.'

CallbackHandler = {
  do: (req, opts) =>
    request req, (err, res, body) ->
      if (err)
        opts.error?(err)
      else
        opts.success?(res, body)
}

PromiseHandler = {
  do: (req, opts) =>
    deferred = Q.defer()
    callbacks =
      error: (err) -> deferred.reject(err)
      success: (res, body) -> deferred.resolve({result: res, body: body})
    opts = merge(true, opts, callbacks)
    CallbackHandler.do(req, opts)

    return deferred.promise
}

class Buttercoin
  constructor: (@builder, @auth, @handler) ->

  pipeline: (method, path, opts, userOpts) =>
    opts = merge.recursive(true, opts or {}, userOpts or {})
    # TODO - test for header inclusion
    opts.headers = merge(true, @builder.endpoint.headers or {}, opts?.headers or {})
    req = @auth.authorize(@builder.buildRequest(method, path, opts), opts)
    @handler.do(req, opts)

  simplePipeline: (method, path, opts, userOpts) =>
    @pipeline(method, path, opts, userOpts).then (res) ->
      if res.result.statusCode is 200
        JSON.parse(res.result.body)
      else
        res

  getOrderBook: (opts) => @simplePipeline('GET', 'orderbook', auth: false, opts)
  getTradeHistory: (opts) => @simplePipeline('GET', 'trades', auth: false, opts)
  getTicker: (opts) => @simplePipeline('GET', 'ticker', auth: false, opts)

  getBalances: (opts) => @simplePipeline('GET', 'account/balances', auth: true, opts)
  getDepositAddress: (opts) => @simplePipeline('GET', 'account/depositAddress', auth: true, opts)

  postOrder: (order) =>
    unless order instanceof CreateOrder
      throw new Error("Invalid argument to createOrder: #{order}")
    @pipeline('POST', 'orders', body: order).then (res) ->
      if res.result.statusCode is 202
        loc = res.result.headers.location
        {url: loc, orderId: loc.split('/').pop()}
      else
        res

  getOrders: (query) =>
    @pipeline('GET', 'orders', query: query).then (res) ->
      if res.result.statusCode is 200
        JSON.parse(res.result.body).results
      else
        res

  getOrderById:(orderId, opts) =>
    @simplePipeline('GET', "/orders/#{orderId}", auth: true, opts)

  cancelOrder: (orderId, opts) =>
    @pipeline('DELETE', "orders/#{orderId}", auth: true, opts).then (res) ->
      if res.result.statusCode is 204
        'OK'
      else
        res

class CredentialSelector
  constructor: (@tokenProvider, @buildClient) ->
  as: (evidence) => @buildClient(evidence)


Buttercoin.withKeySecret = (api_key, api_secret, endpoint, version) ->
  KeySecretAuthorizer = require('./auth/keysecret')
  new Buttercoin(
    new RequestBuilder(endpoint, version),
    new KeySecretAuthorizer(api_key, api_secret),
    PromiseHandler
  )

Buttercoin.withOAuth2 = (tokenProvider, endpoint, version) ->
  OAuth2Authorizer = require('./auth/oauth2')
  new CredentialSelector tokenProvider, (evidence) ->
    new Buttercoin(
      new RequestBuilder(endpoint, version),
      new OAuth2Authorizer(tokenProvider, evidence),
      PromiseHandler)

#Buttercoin.PromiseHandler = PromiseHandler
#Buttercoin.CallbackHandler = CallbackHandler

module.exports = Buttercoin
