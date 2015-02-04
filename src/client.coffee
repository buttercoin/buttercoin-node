OAuth2Authorizer = require('./auth/oauth2')
RequestBuilder = require('./request_builder')
CreateOrder = require ('./requests/create_order')

class Buttercoin
  constructor: (@builder, @auth) ->

  pipeline: (method, path, opts) =>
    req = @auth.authorize @builder.buildRequest(method, path, opts)

  getOrderBook: () => @pipeline('GET', 'orderbook', auth: false)
  getTradeHistory: () => @pipeline('GET', 'trades', auth: false)
  getTicker: () => @pipeline('GET', 'ticker', auth: false)

  getBalances: () => @pipeline('GET', 'account/balances')
  postOrder: (order) =>
    unless order instanceof CreateOrder
      throw new Error("Invalid argument to createOrder: #{order}")
    @pipeline('POST', 'orders', body: order)

Buttercoin::withApiCredentials = (api_key, api_secret, endpoint, version) ->

Buttercoin::withOAuth2 = (tokenProvider, endpoint, version) ->
  new Buttercoin(
    new RequestBuilder(endpoint, version),
    new OAuth2Authorizer(tokenProvider))

module.exports = Buttercoin
