should = require('should')
Endpoint = require('../lib/endpoint')

describe "Endpoint", ->
  it "should not be null or undefined", ->
    Endpoint.should.not.equal null
    Endpoint.should.not.equal undefined

  it "should have defaults for production and sandbox/staging", ->
    Endpoint.defaults.production.host.should.equal 'api.buttercoin.com'
    Endpoint.defaults.staging.host.should.equal 'www-sandbox.buttercoin.com'
    Endpoint.defaults.sandbox.host.should.equal 'www-sandbox.buttercoin.com'

  it "should be able to format a url", ->
    e = Endpoint.defaults.production
    url = e.formatUrl
      pathname: '/test/url'
      query:
        foo: 'bar'
    url.should.equal 'https://api.buttercoin.com/test/url?foo=bar'

  it "should be able to create a custom url", ->
    e = new Endpoint
      host: "localhost"
      protocol: "http"
      port: "9003"

    url = e.formatUrl(pathname: '/test/url')
    url.should.equal 'http://localhost:9003/test/url'
