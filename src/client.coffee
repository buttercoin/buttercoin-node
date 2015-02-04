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
    opts = merge(opts or {}, userOpts or {})
    req = @auth.authorize(@builder.buildRequest(method, path, opts))
    @handler.do(req, opts)

  getOrderBook: (opts) => @pipeline('GET', 'orderbook', auth: false, opts)
  getTradeHistory: (opts) => @pipeline('GET', 'trades', auth: false, opts)
  getTicker: (opts) => @pipeline('GET', 'ticker', auth: false, opts)

  getBalances: () => @pipeline('GET', 'account/balances')

  postOrder: (order) =>
    unless order instanceof CreateOrder
      throw new Error("Invalid argument to createOrder: #{order}")
    @pipeline('POST', 'orders', body: order)

Buttercoin::withKeySecret = (api_key, api_secret, endpoint, version) ->
  KeySecretAuthorizer = require('./auth/keysecret')
  new Buttercoin(
    new RequestBuilder(endpoint, version),
    new KeySecretAuthorizer(api_key, api_secret),
    PromiseHandler
  )

Buttercoin::withOAuth2 = (tokenProvider, endpoint, version) ->
  OAuth2Authorizer = require('./auth/oauth2')
  new Buttercoin(
    new RequestBuilder(endpoint, version),
    new OAuth2Authorizer(tokenProvider),
    PromiseHandler
  )

Buttercoin::PromiseHandler = PromiseHandler
Buttercoin::CallbackHandler = CallbackHandler

module.exports = Buttercoin
