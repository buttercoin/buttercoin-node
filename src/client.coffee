RequestBuilder = require('./request_builder')
CreateOrder = require ('./requests/create_order')
request = require('request')
merge = require('merge')
Q = require('q')

UNEXPECTED_RESPONSE = 'Unexpected response format. You might be using the wrong version of the API, or this API Client is out of date.'

CallbackHandler = {
  do: (req, opts) =>
    console.log 'request:', req
    console.log 'opts:', opts

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

  getOrderBook: (opts) => @pipeline('GET', 'orderbook', auth: false, opts)
  getTradeHistory: (opts) => @pipeline('GET', 'trades', auth: false, opts)
  getTicker: (opts) => @pipeline('GET', 'ticker', auth: false, opts)

  getBalances: (opts) => @pipeline('GET', 'account/balances', auth: true, opts)

  postOrder: (order) =>
    unless order instanceof CreateOrder
      throw new Error("Invalid argument to createOrder: #{order}")
    @pipeline('POST', 'orders', body: order).then (res) ->
      if res.result.statusCode is 202
        loc = res.result.headers.location
        {url: loc, orderId: loc.split('/').pop()}
      else
        res

  cancelOrder: (orderId, opts) =>
    @pipeline('DELETE', "orders/#{orderId}", auth: true, opts)

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
