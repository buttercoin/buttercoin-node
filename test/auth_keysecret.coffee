should = require('should')
KeySecretAuthorizer = require('../src/auth/keysecret.coffee')
RequestBuilder = require('../src/request_builder')

describe 'Buttercoin key/secret authorizer', ->
  it 'should export a single class', ->
    KeySecretAuthorizer.should.be.type 'function'
    KeySecretAuthorizer.name.should.equal 'KeySecretAuthorizer'

  describe 'initialization', ->
    it 'should have a key/secret pair', ->
      k = 'abcdefghijklmnopqrstuvwxyz123456'
      s = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
      auth = new KeySecretAuthorizer(k, s)
      auth.key.should.equal(k)
      auth.secret.should.equal(s)

    it 'should reject a null or undefined key', ->
      s = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
      (-> new KeySecretAuthorizer(k, s)).should.throw('API Key parameter must be specified and be of length 32 characters')

      k = null
      (-> new KeySecretAuthorizer(k, s)).should.throw('API Key parameter must be specified and be of length 32 characters')

    it 'should reject a short key', ->
      k = 'too_short'
      s = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
      (-> new KeySecretAuthorizer(k, s)).should.throw('API Key parameter must be specified and be of length 32 characters')

    it 'should reject a null or undefined secret', ->
      k = 'abcdefghijklmnopqrstuvwxyz123456'
      (-> new KeySecretAuthorizer(k, s)).should.throw('API Secret parameter must be specified and be of length 32 characters')

      s = null
      (-> new KeySecretAuthorizer(k, s)).should.throw('API Secret parameter must be specified and be of length 32 characters')

    it 'should reject a short secret', ->
      k = 'abcdefghijklmnopqrstuvwxyz123456'
      s = 'too_short'
      (-> new KeySecretAuthorizer(k, s)).should.throw('API Secret parameter must be specified and be of length 32 characters')

  k = 'abcdefghijklmnopqrstuvwxyz123456'
  s = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
  auth = new KeySecretAuthorizer(k, s)
  builder = new RequestBuilder()

  describe 'signing', ->
    it 'should produce expected signatures for known values', ->
      signature = auth.sign(
        '1403558182457https://api.buttercoin.com/v1/key',
        'abcdefghijklmnopqrstuvwxyz123456')
      signature.should.equal 'amakcIy40XLCUaSz6urhl+687F2pIexux+TJ2bl+66I='

    it 'should produce signing strings w/ params for GET requests', ->
      req = builder.buildRequest('GET', 'account/balances', qs: {foo: 'bar', x: 1})
      auth.stringToSign(req).should.equal(
        'https://sandbox.buttercoin.com/v1/account/balances?foo=bar&x=1')

    it 'should produce signing strings w/ body for POST requests', ->
      req = builder.buildRequest('POST', 'orders', body: {foo: 'bar', x: 3})
      auth.stringToSign(req).should.equal(
        'https://sandbox.buttercoin.com/v1/orders{"foo":"bar","x":3}')

  describe 'authenticated requests', ->
    it 'should add signing headers to an authenticated requests', ->
      timestamp = 1423078156750
      req =
        method: 'GET'
        url: 'https://sandbox.buttercoin.com/v1/account/balances'
        _auth: true
      expected = auth.sign(timestamp + req.url, s)

      req = auth.authorize(req, timestamp)
      req.headers['X-Buttercoin-Access-Key'].should.equal k
      req.headers['X-Buttercoin-Signature'].should.equal expected
      req.headers['X-Buttercoin-Date'].should.equal timestamp

    it 'should calculate a timestamp if one is not provided', ->
      early = (new Date).getTime()
      req = auth.authorize(builder.buildRequest('GET', '/'))
      req.headers['X-Buttercoin-Date'].should.be.type 'number'
      req.headers['X-Buttercoin-Date'].should.equal early # TODO - should strictly be >=

    it 'should not add signing headers to an unauthenticated request', ->
      req = auth.authorize({_auth: false})
      should.not.exist(req.headers?['X-Buttercoin-Access-Key'])
      should.not.exist(req.headers?['X-Buttercoin-Signature'])
      should.not.exist(req.headers?['X-Buttercoin-Date'])
