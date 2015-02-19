var request = require('request');
var crypto = require('crypto');
var qs = require('qs');
var merge = require('merge');

var UNEXPECTED_RESPONSE = 'Unexpected response format. You might be using the wrong version of the API, or this API Client is out of date.';

var environments = {
  production: { host: "api.buttercoin.com" },
  sandbox: { host: "sandbox.buttercoin.com" },
  staging: { host: "sandbox.buttercoin.com" }
};

function initWithApiCredentials(api_key, api_secret, mode, version) {
  if (!api_key || api_key.length !== 32)
    throw new Error('API Key parameter must be specified and be of length 32 characters');

  if (!api_secret || api_secret.length !== 32)
    throw new Error('API Secret parameter must be specified and be of length 32 characters');

  var api_url;
  var headers;

  if (environments[mode]) { mode = environments[mode]; }
  if (mode !== null && typeof(mode) === 'object' && mode.host) {
    var protocol = mode.protocol || "https";
    var port = "";
    if(mode.port) { port = ":" + mode.port; }
    api_url = protocol + "://" + mode.host + port;
    headers = mode.headers || {};
  } else {
    throw ("Invalid mode: " + mode);
  }

  return new Buttercoin(api_key, api_secret, api_url, headers, version);
}

function initWithOAuth(client_id, client_secret) {
}

module.exports.withApiKey = initWithApiCredentials;
module.exports.withOAuth = initWithOAuth;

function Buttercoin (api_key, api_secret, api_url, headers, version) {
  this.apiKey = api_key;
  this.apiSecret = api_secret;
  this.version = version || "v1"; // default to latest API version as of this Client release
  this.headers = headers || {};
  this.apiUrl = api_url;
}

Buttercoin.prototype.buildUrl = function (endpoint) {
  return this.apiUrl + "/" + this.version + "/" + endpoint;
};

Buttercoin.prototype.signUrl = function (urlString, timestamp) {
  urlString = new Buffer(timestamp + urlString, 'UTF-8').toString('base64');
  var signedHash = crypto.createHmac('sha256', this.apiSecret).update(urlString).digest('base64');
  return signedHash;
};

Buttercoin.prototype.getHeaders = function (signature, timestamp) {
  var headers = merge(true, this.headers);
  if (signature) {
    headers['X-Buttercoin-Access-Key'] = this.apiKey;
    headers['X-Buttercoin-Signature'] = signature;
    headers['X-Buttercoin-Date'] = timestamp;
  }

  return headers;
};

Buttercoin.prototype.buildRequest = function (method, endpoint, timestamp, body) {
  if (typeof timestamp === 'undefined') { timestamp = new Date().getTime(); }
  if (typeof body === 'undefined') { body = {}; }
  var url = this.buildUrl(endpoint);
  var options = {
    url: url,
    strictSSL: true
  };
  var signature;
  if (method === 'GET') {
    var paramString = (Object.getOwnPropertyNames(body).length === 0) ? '' : "?" + qs.stringify(body);
    signature = this.signUrl(url + paramString, timestamp);
    options.qs = body;
    options.json = true;
  } else if (method === 'POST') {
    signature = this.signUrl(url + JSON.stringify(body), timestamp);
    options.json = body;
  } else {
    signature = this.signUrl(url, timestamp);
    options.json = true;
  }
  options.method = method;
  options.headers = this.getHeaders(signature, timestamp);

  return options;
};

Buttercoin.prototype.getKey = function (timestamp, callback) {
  if (arguments.length === 1) {
    callback = timestamp;
    timestamp = undefined;
  }

  var endpoint = 'key';
  var options = this.buildRequest('GET', endpoint, timestamp);

  request(options, function (err, res, body) {
    if (err) {
      callback(err);
    } else {
      if (res.statusCode === 200) {
        if (body.permissions)
          callback(null, body.permissions);
        else
        callback({ errors: [{ message: UNEXPECTED_RESPONSE }]});
      } else {
        callback(body);
      }
    }
  });
};

Buttercoin.prototype.getBalances = function (timestamp, callback) {
  if (arguments.length === 1) {
    callback = timestamp;
    timestamp = undefined;
  }

  var endpoint = 'account/balances';
  var options = this.buildRequest('GET', endpoint, timestamp);

  request(options, function (err, res, body) {
    if (err) {
      callback(err);
    } else {
      if (res.statusCode === 200) {
        callback(null, body);
      } else {
        callback(body);
      }
    }
  });
};

Buttercoin.prototype.getDepositAddress = function (timestamp, callback) {
  if (arguments.length === 1) {
    callback = timestamp;
    timestamp = undefined;
  }

  var endpoint = 'account/depositAddress';
  var options = this.buildRequest('GET', endpoint, timestamp);

  request(options, function (err, res, body) {
    if (err) {
      callback(err);
    } else {
      if (res.statusCode === 200) {
        if (body.address)
          callback(null, body.address);
        else
					callback({ errors: [{ message: UNEXPECTED_RESPONSE }]});
      } else {
        callback(body);
      }
    }
  });
};

Buttercoin.prototype.getOrders = function (queryParams, timestamp, callback) {
  this.getRecords('orders', queryParams, timestamp, callback);
};

Buttercoin.prototype.getOrderById = function (orderId, timestamp, callback) {
  var endpoint = 'orders/' + orderId;
  this.getRecordById(endpoint, timestamp, callback);
};

Buttercoin.prototype.getOrder = Buttercoin.prototype.getOrderById;

Buttercoin.prototype.getOrderByUrl = function (url, timestamp, callback) {
  var orderId = url.substring(url.lastIndexOf('/')+1);
  return this.getOrderById(orderId, timestamp, callback);
};

Buttercoin.prototype.cancelOrder = function (orderId, timestamp, callback) {
  var endpoint = 'orders/' + orderId;
  this.cancelRecord(endpoint, timestamp, callback);
};

Buttercoin.prototype.createOrder = function (params, timestamp, callback) {
  var endpoint = 'orders';
  this.createRecord(endpoint, params, timestamp, callback);
};

Buttercoin.prototype.getTransactions = function (queryParams, timestamp, callback) {
  this.getRecords('transactions', queryParams, timestamp, callback);
};

Buttercoin.prototype.getTransactionById = function (trxnId, timestamp, callback) {
  var endpoint = 'transactions/' + trxnId;
  this.getRecordById(endpoint, timestamp, callback);
};

Buttercoin.prototype.getTransaction = Buttercoin.prototype.getTransactionById;

Buttercoin.prototype.getTransactionByUrl = function (url, timestamp, callback) {
  var trxnId = url.substring(url.lastIndexOf('/')+1);
  return this.getTransactionById(trxnId, timestamp, callback);
};

Buttercoin.prototype.cancelTransaction = function (trxnId, timestamp, callback) {
  var endpoint = 'transactions/' + trxnId;
  this.cancelRecord(endpoint, timestamp, callback);
};

Buttercoin.prototype.createDeposit = function (params, timestamp, callback) {
  var endpoint = 'transactions/deposit';
  this.createRecord(endpoint, params, timestamp, callback);
};

Buttercoin.prototype.createWithdrawal = function (params, timestamp, callback) {
  var endpoint = 'transactions/withdrawal';
  this.createRecord(endpoint, params, timestamp, callback);
};

Buttercoin.prototype.send = function (params, timestamp, callback) {
  var endpoint = 'transactions/send';
  this.createRecord(endpoint, params, timestamp, callback);
};

Buttercoin.prototype.sendBitcoin = Buttercoin.prototype.send;

Buttercoin.prototype.getOrderbook = function (callback) {
  var url = this.buildUrl('orderbook');
  this.getUnauthenticated(url, callback);
};

Buttercoin.prototype.getTicker = function (callback) {
  var url = this.buildUrl('ticker');
  this.getUnauthenticated(url, callback);
};

Buttercoin.prototype.getTradeHistory = function (callback) {
  var url = this.buildUrl('trades');
  this.getUnauthenticated(url, callback);
};

Buttercoin.prototype.getUnauthenticated = function (url, callback) {
  request.get({
    url: url,
    json: true,
    strictSSL: true,
    headers: this.headers
  }, function (err, res, body) {
    if (err) {
      callback(err);
    } else {
      if (res.statusCode === 200) {
        callback(null, body);
      } else {
        callback(body);
      }
    }
  });
};

Buttercoin.prototype.getRecords = function (endpoint, queryParams, timestamp, callback) {
  // queryParams and timestamp are optional fields, so handle dynamic method parameters
  if (typeof callback === 'undefined') {
    if (typeof timestamp === 'undefined') {
      callback = queryParams;
      timestamp = undefined;
      queryParams = undefined;
    } else {
      callback = timestamp;
      if (+queryParams && isFinite(queryParams) && !(queryParams % 1)) {
        timestamp = queryParams;
        queryParams = undefined;
      } else {
        timestamp = undefined;
      }
    }
  }

  var options = this.buildRequest('GET', endpoint, timestamp, queryParams);

  request(options, function (err, res, body) {
    if (err) {
      callback(err);
    } else {
      if (res.statusCode === 200) {
        if (body.results)
          callback(null, body.results);
        else
          callback({ errors: [{ message: UNEXPECTED_RESPONSE }]});
      } else {
        callback(body);
      }
    }
  });
};

Buttercoin.prototype.getRecordById = function(endpoint, timestamp, callback) {
  if (typeof callback === 'undefined') {
    callback = timestamp;
    timestamp = undefined;
  }

  var options = this.buildRequest('get', endpoint, timestamp);

  request(options, function (err, res, body) {
    if (err) {
      callback(err);
    } else {
      if (res.statusCode === 200) {
        callback(null, body);
      } else {
        callback(body);
      }
    }
  });
};

Buttercoin.prototype.createRecord = function(endpoint, body, timestamp, callback) {
  if (typeof callback === 'undefined') {
    callback = timestamp;
    timestamp = undefined;
  }

  var options = this.buildRequest('POST', endpoint, timestamp, body);

  request(options, function (err, res, body) {
    if (err) {
      callback(err);
    } else {
      if (res.statusCode === 201) {
        callback(null, { status: 201, message: 'This operation requires email confirmation' });
      } else if (res.statusCode === 202) {
        callback(null, { status: 202, url: res.headers.location });
      } else {
        callback(body);
      }
    }
  });
};

Buttercoin.prototype.cancelRecord = function(endpoint, timestamp, callback) {
  if (typeof callback === 'undefined') {
    callback = timestamp;
    timestamp = undefined;
  }

  var options = this.buildRequest('DELETE', endpoint, timestamp);

  request(options, function (err, res, body) {
    if (err) {
      callback(err);
    } else {
      if (res.statusCode === 204) {
        callback(null, { status: 204, message: 'This operation has completed successfully' });
      } else {
        callback(body);
      }
    }
  });
};
