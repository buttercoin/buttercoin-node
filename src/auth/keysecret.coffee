crypto = require('crypto')
qs = require('qs')

class KeySecretAuthorizer
  constructor: (@key, @secret) ->
    if not @key or @key.length isnt 32
      throw new Error('API Key parameter must be specified and be of length 32 characters')
    if not @secret or @secret.length isnt 32
      throw new Error('API Secret parameter must be specified and be of length 32 characters')

  stringToSign: (request) ->
    if request.method is 'GET'
      queryString = if request.hasOwnProperty('qs') then "?" + qs.stringify(request.qs) else ""
      request.url + queryString
    else if request.method is 'POST'
      request.url + JSON.stringify(request.body)
    else
      request.url

  sign: (data, secret) ->
    base64data = new Buffer(data, "UTF-8").toString("base64")
    signedHash = crypto.createHmac("sha256", secret).update(base64data).digest("base64")
    signedHash

  authorize: (request, timestamp) =>
    if request._auth
      timestamp ?= (new Date).getTime
      signature = @sign(timestamp + @stringToSign(request), @secret)

      request.headers ?= {}
      request.headers['X-Buttercoin-Access-Key'] = @key
      request.headers['X-Buttercoin-Signature'] = signature
      request.headers['X-Buttercoin-Date'] = timestamp

    delete(request._auth)
    request

module.exports = KeySecretAuthorizer
