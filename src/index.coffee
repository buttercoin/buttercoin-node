module.exports =
  Client: require('./client')
  Endpoint: require('./endpoint')

#request = require("request")
#sign = require('./signing')
#qs = require("qs")
#merge = require("merge")

#UNEXPECTED_RESPONSE = "Unexpected response format.  You might be using the wrong version of the API, or Buttercoin might be MESSING up."

#initWithApiCredentials = (api_key, api_secret, endpoint, version) ->
  #throw new Error("API Key parameter must be specified and be of length 32 characters")  if not api_key or api_key.length isnt 32
  #throw new Error("API Secret parameter must be specified and be of length 32 characters")  if not api_secret or api_secret.length isnt 32
  #endpoint = endpoints[endpoint] if endpoints[endpoint]
  #if endpoint isnt null and typeof endpoint is "object" and endpoint.host
    #protocol = endpoint.protocol or "https"
    #port = if endpoint.port then ":#{endpoint.port}" else ""
    #api_url = protocol + "://" + endpoint.host + port
    #headers = endpoint.headers or {}
    #new Buttercoin(api_key, api_secret, api_url, headers, version)
  #else
    #throw "Invalid API endpoint: #{endpoint}"

#initWithOAuth = (client_id, client_secret) ->
  #throw "OAuth not yet supported"

#Buttercoin = (api_key, api_secret, api_url, headers, version) ->
  #@apiKey = api_key
  #@apiSecret = api_secret
  #@version = version or "v1" # default to latest API version as of this Client release
  #@headers = headers or {}
  #@apiUrl = api_url
  #return

#module.exports =
  #withApiKey: initWithApiCredentials
  #withOAuth: initWithOAuth

#Buttercoin::buildUrl = (endpoint) ->
  #@apiUrl + "/" + @version + "/" + endpoint

#Buttercoin::signUrl = (urlString, timestamp) -> sign(timestamp + urlString, @apiSecret)

#Buttercoin::getHeaders = (signature, timestamp) ->
  #headers = merge(true, @headers)
  #if signature
    #headers["X-Buttercoin-Access-Key"] = @apiKey
    #headers["X-Buttercoin-Signature"] = signature
    #headers["X-Buttercoin-Date"] = timestamp
  #headers

#Buttercoin::buildRequest = (method, endpoint, timestamp, body) ->
  #timestamp = new Date().getTime()  if typeof timestamp is "undefined"
  #body = {}  if typeof body is "undefined"
  #url = @buildUrl(endpoint)
  #options =
    #url: url
    #strictSSL: true

  #signature = undefined
  #if method is "GET"
    #paramString = (if (Object.getOwnPropertyNames(body).length is 0) then "" else "?" + qs.stringify(body))
    #signature = @signUrl(url + paramString, timestamp)
    #options.qs = body
    #options.json = true
  #else if method is "POST"
    #signature = @signUrl(url + JSON.stringify(body), timestamp)
    #options.json = body
  #else
    #signature = @signUrl(url, timestamp)
    #options.json = true
  #options.method = method
  #options.headers = @getHeaders(signature, timestamp)
  #options

#Buttercoin::getKey = (timestamp, callback) ->
  #if arguments.length is 1
    #callback = timestamp
    #timestamp = `undefined`
  #endpoint = "key"
  #options = @buildRequest("GET", endpoint, timestamp)
  #request options, (err, res, body) ->
    #if err
      #callback err
    #else
      #if res.statusCode is 200
        #if body.permissions
          #callback null, body.permissions
        #else
          #callback errors: [message: UNEXPECTED_RESPONSE]
      #else
        #callback body
    #return

  #return

#Buttercoin::getBalances = (timestamp, callback) ->
  #if arguments.length is 1
    #callback = timestamp
    #timestamp = `undefined`
  #endpoint = "account/balances"
  #options = @buildRequest("GET", endpoint, timestamp)
  #request options, (err, res, body) ->
    #if err
      #callback err
    #else
      #if res.statusCode is 200
        #callback null, body
      #else
        #callback body
    #return

  #return

#Buttercoin::getDepositAddress = (timestamp, callback) ->
  #if arguments.length is 1
    #callback = timestamp
    #timestamp = `undefined`
  #endpoint = "account/depositAddress"
  #options = @buildRequest("GET", endpoint, timestamp)
  #request options, (err, res, body) ->
    #if err
      #callback err
    #else
      #if res.statusCode is 200
        #if body.address
          #callback null, body.address
        #else
          #callback errors: [message: UNEXPECTED_RESPONSE]
      #else
        #callback body
    #return

  #return

#Buttercoin::getOrders = (queryParams, timestamp, callback) ->
  #@getRecords "orders", queryParams, timestamp, callback
  #return

#Buttercoin::getOrderById = (orderId, timestamp, callback) ->
  #endpoint = "orders/" + orderId
  #@getRecordById endpoint, timestamp, callback
  #return

#Buttercoin::getOrder = Buttercoin::getOrderById
#Buttercoin::getOrderByUrl = (url, timestamp, callback) ->
  #orderId = url.substring(url.lastIndexOf("/") + 1)
  #@getOrderById orderId, timestamp, callback

#Buttercoin::cancelOrder = (orderId, timestamp, callback) ->
  #endpoint = "orders/" + orderId
  #@cancelRecord endpoint, timestamp, callback
  #return

#Buttercoin::createOrder = (params, timestamp, callback) ->
  #endpoint = "orders"
  #@createRecord endpoint, params, timestamp, callback
  #return

#Buttercoin::getTransactions = (queryParams, timestamp, callback) ->
  #@getRecords "transactions", queryParams, timestamp, callback
  #return

#Buttercoin::getTransactionById = (trxnId, timestamp, callback) ->
  #endpoint = "transactions/" + trxnId
  #@getRecordById endpoint, timestamp, callback
  #return

#Buttercoin::getTransaction = Buttercoin::getTransactionById
#Buttercoin::getTransactionByUrl = (url, timestamp, callback) ->
  #trxnId = url.substring(url.lastIndexOf("/") + 1)
  #@getTransactionById trxnId, timestamp, callback

#Buttercoin::cancelTransaction = (trxnId, timestamp, callback) ->
  #endpoint = "transactions/" + trxnId
  #@cancelRecord endpoint, timestamp, callback
  #return

#Buttercoin::createDeposit = (params, timestamp, callback) ->
  #endpoint = "transactions/deposit"
  #@createRecord endpoint, params, timestamp, callback
  #return

#Buttercoin::createWithdrawal = (params, timestamp, callback) ->
  #endpoint = "transactions/withdrawal"
  #@createRecord endpoint, params, timestamp, callback
  #return

#Buttercoin::send = (params, timestamp, callback) ->
  #endpoint = "transactions/send"
  #@createRecord endpoint, params, timestamp, callback
  #return

#Buttercoin::sendBitcoin = Buttercoin::send
#Buttercoin::getOrderbook = (callback) ->
  #url = @buildUrl("orderbook")
  #@getUnauthenticated url, callback
  #return

#Buttercoin::getTicker = (callback) ->
  #url = @buildUrl("ticker")
  #@getUnauthenticated url, callback
  #return

#Buttercoin::getTradeHistory = (callback) ->
  #url = @buildUrl("trades")
  #@getUnauthenticated url, callback
  #return

#Buttercoin::getUnauthenticated = (url, callback) ->
  #request.get
    #url: url
    #json: true
    #strictSSL: true
    #headers: @headers
  #, (err, res, body) ->
    #if err
      #callback err
    #else
      #if res.statusCode is 200
        #callback null, body
      #else
        #callback body
    #return

  #return

#Buttercoin::getRecords = (endpoint, queryParams, timestamp, callback) ->
  ## queryParams and timestamp are optional fields, so handle dynamic method parameters
  #if typeof callback is "undefined"
    #if typeof timestamp is "undefined"
      #callback = queryParams
      #timestamp = `undefined`
      #queryParams = `undefined`
    #else
      #callback = timestamp
      #if +queryParams and isFinite(queryParams) and not (queryParams % 1)
        #timestamp = queryParams
        #queryParams = `undefined`
      #else
        #timestamp = `undefined`
  #options = @buildRequest("GET", endpoint, timestamp, queryParams)
  #request options, (err, res, body) ->
    #if err
      #callback err
    #else
      #if res.statusCode is 200
        #if body.results
          #callback null, body.results
        #else
          #callback errors: [message: UNEXPECTED_RESPONSE]
      #else
        #callback body
    #return

  #return

#Buttercoin::getRecordById = (endpoint, timestamp, callback) ->
  #if typeof callback is "undefined"
    #callback = timestamp
    #timestamp = `undefined`
  #options = @buildRequest("get", endpoint, timestamp)
  #request options, (err, res, body) ->
    #if err
      #callback err
    #else
      #if res.statusCode is 200
        #callback null, body
      #else
        #callback body
    #return

  #return

#Buttercoin::createRecord = (endpoint, body, timestamp, callback) ->
  #if typeof callback is "undefined"
    #callback = timestamp
    #timestamp = `undefined`
  #options = @buildRequest("POST", endpoint, timestamp, body)
  #request options, (err, res, body) ->
    #if err
      #callback err
    #else
      #if res.statusCode is 201
        #callback null,
          #status: 201
          #message: "This operation requires email confirmation"

      #else if res.statusCode is 202
        #callback null,
          #status: 202
          #url: res.headers.location

      #else
        #callback body
    #return

  #return

#Buttercoin::cancelRecord = (endpoint, timestamp, callback) ->
  #if typeof callback is "undefined"
    #callback = timestamp
    #timestamp = `undefined`
  #options = @buildRequest("DELETE", endpoint, timestamp)
  #request options, (err, res, body) ->
    #if err
      #callback err
    #else
      #if res.statusCode is 204
        #callback null,
          #status: 204
          #message: "This operation has completed successfully"

      #else
        #callback body
    #return

  #return
