URL = require('url')

Scopes = [
  "profile",
  "bankview",
  "balances",
  "addresses",
  "buy",
  "sell",
  "cancelorder",
  "fiatdeposit",
  "fiatwithdraw",
  "cryptowithdraw"
]

class OAuth
  @Scopes = Scopes

  authUrl: (endpoint, client_id, redirect_uri, scope, state) =>
    endpoint.formatUrl
      pathname: '/oauth/auth'
      query:
        client_id: client_id
        redirect_uri: redirect_uri
        scope: scope
        state: state

  @newTokenUrl: (endpoint, client_id, client_secret, code, redirect_uri) ->
    endpoint.formatUrl
      pathname: '/oauth/token'
      query:
        grant_type: 'authorization_code'
        code: code
        client_id: client_id
        client_secret: client_secret
        redirect_uri: redirect_uri

  @refreshTokenUrl: (endpoint, client_id, client_secret, refresh_token) ->
    endpoint.formatUrl
      pathname: '/oauth/token'
      query:
        grant_type: 'refresh_token'
        refresh_token: refresh_token
        client_id: client_id
        client_secret: client_secret

module.exports = OAuth
