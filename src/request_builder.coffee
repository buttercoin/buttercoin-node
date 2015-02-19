Endpoint = require('./endpoint')
merge = require('merge')

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
      headers: merge(true, options?.headers or {})
      _auth: if options?.auth isnt undefined then options.auth else true

    if method is 'GET'
      querystring = options?.qs || options?.query || options?.body
      req.qs = querystring if querystring isnt undefined
    else if method is 'POST'
      req.body = options.body if options?.body isnt undefined
      req.json = true

    return req
