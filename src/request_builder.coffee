Endpoint = require('./endpoint')

module.exports = class RequestBuilder
  @defaultVersion = 'v1'
  @defaultEndpoint = Endpoint.defaults.sandbox

  constructor: (@endpoint, @version) ->
    @version = RequestBuilder.defaultVersion unless(@version?)
    @endpoint = RequestBuilder.defaultEndpoint unless(@endpoint?)

  buildRequest: (method, path, options) =>
    path = path.substring(1) if path[0] is '/'

    req =
      method: method
      url: @endpoint.formatUrl(pathname: "#{@version}/#{path}")
      strictSSL: (@endpoint.protocol is 'https')
      _auth: if options?.auth isnt undefined then options.auth else true

    if method is 'GET'
      req.qs = options?.qs || options?.query || options?.body
    req.body = options?.body

    return req
