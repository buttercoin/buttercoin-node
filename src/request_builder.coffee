Endpoint = require('./endpoint')
CreateOrder = require ('./requests/create_order')

module.exports = class RequestBuilder
  @defaultVersion = 'v1'
  @defaultEndpoint = Endpoint.defaults.sandbox

  constructor: (@endpoint, @version) ->
    @version = RequestBuilder.defaultVersion unless(@version?)
    @endpoint = RequestBuilder.defaultEndpoint unless(@endpoint?)

  getOrderbook: () => @buildRequest('GET', 'orderbook', auth: false)
  getTradeHistory: () => @buildRequest('GET', 'trades', auth: false)
  getTicker: () => @buildRequest('GET', 'ticker', auth: false)

  getBalances: () => @buildRequest('GET', 'account/balances')

  createOrder: (order) =>
    unless order instanceof CreateOrder
      throw new Error("Invalid argument to createOrder: #{order}")

    @buildRequest('POST', 'orders', body: order)

  buildRequest: (method, path, options) =>
    req =
      method: method
      url: @endpoint.formatUrl(pathname: "#{@version}/#{path}")
      strictSSL: (@endpoint.protocol is 'https')
      _auth: if options?.auth isnt undefined then options.auth else true

    req.body = options.body if options?.body isnt undefined

    return req
