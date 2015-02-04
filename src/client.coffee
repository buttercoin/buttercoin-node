OAuth2Authorizer = require('./auth/oauth2')
RequestBuilder = require('./request_builder')
CreateOrder = require ('./requests/create_order')
request = require('request')
merge = require('merge')

UNEXPECTED_RESPONSE = 'Unexpected response format. You might be using the wrong version of the API, or this API Client is out of date.'

class CallbackHandler
  do: (req, opts) =>
    error = opts.error
    delete(opts.error)
    success = opts.success
    delete(opts.success)

    request req, (err, res, body) ->
      if (err)
        error?(err)
      else
        success?(res, body)




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

Buttercoin::withApiCredentials = (api_key, api_secret, endpoint, version) ->

Buttercoin::withOAuth2 = (tokenProvider, endpoint, version) ->
  new Buttercoin(
    new RequestBuilder(endpoint, version),
    new OAuth2Authorizer(tokenProvider),
    new CallbackHandler()
  )

module.exports = Buttercoin
