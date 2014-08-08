var should = require('should');

describe("Buttercoin", function () {
  var buttercoin, api_key, api_secret, mode, version;

  describe("setup of client object", function () {
    beforeEach(function() {
      api_key = "";
      api_secret = "";
      mode = "";
      version = "";
    });


    it("should configure the client correctly on new object", function () {
      api_key = "abcdefghijklmnopqrstuvwxyz123456";
      api_secret = "abcdefghijklmnopqrstuvwxyz123456";
      mode = "production";
      version = "v1";
      buttercoin = require('../')(api_key, api_secret, mode, version);

      should.exist(buttercoin);
      buttercoin.apiKey.should.equal(api_key);
      buttercoin.apiSecret.should.equal(api_secret);
      buttercoin.apiUrl.should.equal('https://api.buttercoin.com');
      buttercoin.version.should.equal(version);
    });

    it("should throw an error if no api_key is present", function () {
      try {
        buttercoin = require('../')();
      } catch (error) {
        should.exist(error);
        error.message.should.equal("API Key parameter must be specified and be of length 32 characters");
      }
    });

    it("should throw an error if api_key is incorrect length", function () {
      try {
        buttercoin = require('../')('too_short');
      } catch (error) {
        should.exist(error);
        error.message.should.equal("API Key parameter must be specified and be of length 32 characters");
      }
    });

    it("should throw an error if no api_secret is present", function () {
      try {
        buttercoin = require('../')('abcdefghijklmnopqrstuvwxyz123456');
      } catch (error) {
        should.exist(error);
        error.message.should.equal("API Secret parameter must be specified and be of length 32 characters");
      }
    });

    it("should throw an error if api_secret is incorrect length", function () {
      try {
        buttercoin = require('../')('abcdefghijklmnopqrstuvwxyz123456', 'too_short');
      } catch (error) {
        should.exist(error);
        error.message.should.equal("API Secret parameter must be specified and be of length 32 characters");
      }
    });

    it("should point to staging if mode is not production", function () {
      buttercoin = require('../')('abcdefghijklmnopqrstuvwxyz123456', 'abcdefghijklmnopqrstuvwxyz123456', 'staging');
      buttercoin.apiUrl.should.equal('https://api.qa.dcxft.com');
    });

    it("should build a url correctly with the given endpoint, sign the url and build the headers", function () {
      buttercoin = require('../')('abcdefghijklmnopqrstuvwxyz123457', 'abcdefghijklmnopqrstuvwxyz123456', 'production');
      var url = buttercoin.buildUrl('key');
      url.should.equal('https://api.buttercoin.com/v1/key');

      var timestamp = '1403558182457';
      var signature = buttercoin.signUrl(url, timestamp);
      signature.should.equal("amakcIy40XLCUaSz6urhl+687F2pIexux+TJ2bl+66I=");

      var headers = buttercoin.getHeaders(signature, timestamp);
      headers['X-Buttercoin-Access-Key'].should.equal('abcdefghijklmnopqrstuvwxyz123457');
      headers['X-Buttercoin-Signature'].should.equal('amakcIy40XLCUaSz6urhl+687F2pIexux+TJ2bl+66I=');
      headers['X-Buttercoin-Date'].should.equal('1403558182457');
    });

  });
  
});
