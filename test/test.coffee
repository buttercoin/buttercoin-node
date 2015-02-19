#should = require("should")

#clientWithMode = (mode) ->
  #require("../").withApiKey "abcdefghijklmnopqrstuvwxyz123457", "abcdefghijklmnopqrstuvwxyz123456", mode
#describe "Buttercoin", ->
  #buttercoin = undefined
  #api_key = undefined
  #api_secret = undefined
  #mode = undefined
  #version = undefined
  #describe "setup of client object", ->
    #beforeEach ->
      #api_key = ""
      #api_secret = ""
      #mode = ""
      #version = ""
      #return

    #it "should configure the client correctly on new object", ->
      #api_key = "abcdefghijklmnopqrstuvwxyz123456"
      #api_secret = "abcdefghijklmnopqrstuvwxyz123456"
      #mode = "production"
      #version = "v1"
      #buttercoin = require("../").withApiKey(api_key, api_secret, mode, version)
      #should.exist buttercoin
      #buttercoin.apiKey.should.equal api_key
      #buttercoin.apiSecret.should.equal api_secret
      #buttercoin.apiUrl.should.equal "https://api.buttercoin.com"
      #buttercoin.version.should.equal version
      #return

    #it "should throw an error if no api_key is present", ->
      #try
        #buttercoin = require("../").withApiKey()
      #catch error
        #should.exist error
        #error.message.should.equal "API Key parameter must be specified and be of length 32 characters"
      #return

    #it "should throw an error if api_key is incorrect length", ->
      #try
        #buttercoin = require("../").withApiKey("too_short")
      #catch error
        #should.exist error
        #error.message.should.equal "API Key parameter must be specified and be of length 32 characters"
      #return

    #it "should throw an error if no api_secret is present", ->
      #try
        #buttercoin = require("../").withApiKey("abcdefghijklmnopqrstuvwxyz123456")
      #catch error
        #should.exist error
        #error.message.should.equal "API Secret parameter must be specified and be of length 32 characters"
      #return

    #it "should throw an error if api_secret is incorrect length", ->
      #try
        #buttercoin = require("../").withApiKey("abcdefghijklmnopqrstuvwxyz123456", "too_short")
      #catch error
        #should.exist error
        #error.message.should.equal "API Secret parameter must be specified and be of length 32 characters"
      #return

    #it "should point to staging if mode is not production", ->
      #buttercoin = clientWithMode("staging")
      #buttercoin.apiUrl.should.equal "https://sandbox.buttercoin.com"
      #return

    #it "should allow for the specificatoin of a custom endpoint", ->
      #buttercoin = clientWithMode(
        #protocol: "http"
        #host: "localhost"
        #port: 1234
        #headers:
          #"X-Forwarded-For": "127.0.0.1"
      #)
      #url = buttercoin.buildUrl("key")
      #timestamp = "1403558182457"
      #signature = buttercoin.signUrl(url, timestamp)
      #buttercoin.apiUrl.should.equal "http://localhost:1234"
      #headers = buttercoin.getHeaders(signature, timestamp)
      #headers["X-Forwarded-For"].should.equal "127.0.0.1"
      #return

    #it "should build a url correctly with the given endpoint, sign the url and build the headers", ->
      #buttercoin = clientWithMode("production")
      #url = buttercoin.buildUrl("key")
      #url.should.equal "https://api.buttercoin.com/v1/key"
      #timestamp = "1403558182457"
      #signature = buttercoin.signUrl(url, timestamp)
      #signature.should.equal "amakcIy40XLCUaSz6urhl+687F2pIexux+TJ2bl+66I="
      #headers = buttercoin.getHeaders(signature, timestamp)
      #headers["X-Buttercoin-Access-Key"].should.equal "abcdefghijklmnopqrstuvwxyz123457"
      #headers["X-Buttercoin-Signature"].should.equal "amakcIy40XLCUaSz6urhl+687F2pIexux+TJ2bl+66I="
      #headers["X-Buttercoin-Date"].should.equal "1403558182457"
      #return

    #it "should build the correct options headers based on get method type", ->
      #buttercoin = require("../").withApiKey("abcdefghijklmnopqrstuvwxyz123457", "abcdefghijklmnopqrstuvwxyz123456", "production")
      #method = "GET"
      #endpoint = "orders"
      #timestamp = "1403558182457"
      #body = testParam: "testVal"
      #options = buttercoin.buildRequest(method, endpoint, timestamp, body)
      #options.headers["X-Buttercoin-Access-Key"].should.equal "abcdefghijklmnopqrstuvwxyz123457"
      #options.headers["X-Buttercoin-Signature"].should.equal "M0cug9fN1vRh+eECgBz+bTRhu1u/A7Mgm5cpHPKwWIU="
      #options.headers["X-Buttercoin-Date"].should.equal "1403558182457"
      #options.qs.should.equal body
      #options.json.should.equal true
      #return

    #it "should build the correct options headers based on post method type", ->
      #buttercoin = require("../").withApiKey("abcdefghijklmnopqrstuvwxyz123457", "abcdefghijklmnopqrstuvwxyz123456", "production")
      #method = "POST"
      #endpoint = "orders"
      #timestamp = "1403558182457"
      #body = testParam: "testVal"
      #options = buttercoin.buildRequest(method, endpoint, timestamp, body)
      #options.headers["X-Buttercoin-Access-Key"].should.equal "abcdefghijklmnopqrstuvwxyz123457"
      #options.headers["X-Buttercoin-Signature"].should.equal "KuGR55mSi+OiF6NOu7UG1lgVV7XTMc91IpUuCRdczr4="
      #options.headers["X-Buttercoin-Date"].should.equal "1403558182457"
      #options.hasOwnProperty("qs").should.equal false
      #options.json.should.equal body
      #return

    #it "should build the correct options headers based on post method type", ->
      #buttercoin = require("../").withApiKey("abcdefghijklmnopqrstuvwxyz123457", "abcdefghijklmnopqrstuvwxyz123456", "production")
      #method = "DELETE"
      #endpoint = "orders/my_order_id"
      #timestamp = "1403558182457"
      #body = testParam: "testVal"
      #options = buttercoin.buildRequest(method, endpoint, timestamp, body)
      #options.headers["X-Buttercoin-Access-Key"].should.equal "abcdefghijklmnopqrstuvwxyz123457"
      #options.headers["X-Buttercoin-Signature"].should.equal "rI9nSlbev0b+wY+qge38n72bGi6RolaLLZ0fnVEiVGM="
      #options.headers["X-Buttercoin-Date"].should.equal "1403558182457"
      #options.hasOwnProperty("qs").should.equal false
      #options.json.should.equal true
      #return

    #return

  #return

