Endpoint = require('./endpoint')
Order = require ('./requests/create_order')

module.exports = class RequestBuilder
  @defaultVersion = 'v1'
  @defaultEndpoint = Endpoint.defaults.sandbox

  constructor: (@endpoint, @version) ->
    @version = RequestBuilder.defaultVersion unless(@version?)
    @endpoint = RequestBuilder.defaultEndpoint unless(@endpoint?)

  getBalances: () =>
    @buildRequest('GET', 'account/balances')

  createOrder: (order) =>
    unless order instanceof Order
      throw new Error("Invalid argument to createOrder: #{order}")

    @buildRequest('POST', 'orders', order)

  buildRequest: (method, path, body) =>
    req =
      method: method
      url: @endpoint.formatUrl(pathname: "#{@version}/#{path}")
      strictSSL: (@endpoint.protocol is 'https')

    req.body = body if body?

    return req
