URL = require('url')
merge = require('merge')

DefaultOptions =
  protocol: 'https'
  headers: {}

class Endpoint
  constructor: (opts) ->
    opts = merge(true, DefaultOptions, opts)
    @host = opts.host
    @protocol = opts.protocol
    @port = opts.port
    @headers = opts.headers

  formatUrl: (opts) ->
    urlObj =
      protocol: @protocol
      hostname: @host
      port: @port

    URL.format(merge(true, urlObj, opts))

  @defaults =
    production: new Endpoint(host: "api.buttercoin.com")
    sandbox: new Endpoint(host: "sandbox.buttercoin.com")
    staging: new Endpoint(host: "sandbox.buttercoin.com")

module.exports = Endpoint
