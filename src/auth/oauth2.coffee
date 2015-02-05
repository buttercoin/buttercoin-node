class OAuth2Authorizer
  constructor: (@tokenProvider, @evidence) ->

  authorize: (request) ->
    if request._auth
      bearer = try
        @tokenProvider(@evidence)
      catch
        null

      throw new Error("No credentials for evidence: #{@evidence}") unless bearer
      request.headers ?= {}
      request.headers.Authorization = "Bearer #{bearer}"

    delete(request._auth)
    request

module.exports = OAuth2Authorizer

