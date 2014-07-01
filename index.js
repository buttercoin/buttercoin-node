var request = require('request');
var crypto = require('crypto');
var qs = require('qs');

var UNEXPECTED_RESPONSE = 'Unexpected response format.  You might be using the wrong version of the API, or Buttercoin might be MESSING up.';

module.exports = function (api_key, api_secret, mode, version) {
  if (!api_key || api_key.length !== 32)
    throw new Error('API Key parameter must be specified and be of length 32 characters');

  if (!api_secret || api_secret.length !== 32)
    throw new Error('API Secret parameter must be specified and be of length 32 characters');

  var api_url = 'https://api.qa.dcxft.com';
  if (mode && mode === 'production')
    api_url = 'https://api.buttercoin.com';
  return new Buttercoin(api_key, api_secret, api_url, version);
};

function Buttercoin (api_key, api_secret, api_url, version) {
  this.apiKey = api_key;
  this.apiSecret = api_secret;
  this.version = version || "v1" // default to latest API version as of this Client release
  this.apiUrl = api_url
};

Buttercoin.prototype.buildUrl = function (endpoint) {
  return this.apiUrl + "/" + this.version + "/" + endpoint;
}

Buttercoin.prototype.signUrl = function (urlString, timestamp) {
  urlString = new Buffer(timestamp + urlString, 'UTF-8').toString('base64');
  var signedHash = crypto.createHmac('sha256', this.apiSecret).update(urlString).digest('base64');
  return signedHash;
};

Buttercoin.prototype.getHeaders = function (signature, timestamp) {
  var headers = {
    'X-Buttercoin-Access-Key': this.apiKey,
    'X-Buttercoin-Signature': signature,
    'X-Buttercoin-Date': timestamp
  }
  return headers;
};

Buttercoin.prototype.getKey = function (timestamp, callback) {
  var url = this.buildUrl('key');
  var signature = this.signUrl(url, timestamp);

  request.get({
    url: url,
    json: true,
    strictSSL: true,
    headers: this.getHeaders(signature, timestamp)
  }, function (err, res, body) {
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
  var url = this.buildUrl('account/balances');
  var signature = this.signUrl(url, timestamp);

  request.get({
    url: url,
    json: true,
    strictSSL: true,
    headers: this.getHeaders(signature, timestamp)
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

Buttercoin.prototype.getDepositAddress = function (timestamp, callback) {
  var url = this.buildUrl('account/depositAddress');
  var signature = this.signUrl(url, timestamp);

  request.get({
    url: url,
    json: true,
    strictSSL: true,
    headers: this.getHeaders(signature, timestamp)
  }, function (err, res, body) {
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
  var url = this.buildUrl('orders');
  var paramString = (queryParams && queryParams.length != 0) ? '' : "?" + qs.stringify(queryParams);
  var signature = this.signUrl(url + paramString, timestamp);

  request.get({
    url: url,
    qs: queryParams,
    json: true,
    strictSSL: true,
    headers: this.getHeaders(signature, timestamp)
  }, function (err, res, body) {
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

Buttercoin.prototype.getOrder = function (orderId, timestamp, callback) {
  var url = this.buildUrl('orders/' + orderId);
  var signature = this.signUrl(url, timestamp);

  request.get({
    url: url,
    json: true,
    strictSSL: true,
    headers: this.getHeaders(signature, timestamp)
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

Buttercoin.prototype.cancelOrder = function (orderId, timestamp, callback) {
  var url = this.buildUrl('orders/' + orderId);
  var signature = this.signUrl(url, timestamp);

  request.del({
    url: url,
    json: true,
    strictSSL: true,
    headers: this.getHeaders(signature, timestamp)
  }, function (err, res, body) {
    if (err) {
      callback(err);
    } else {
      if (res.statusCode === 204) {
        callback(null, { status: 204, message: 'Order canceled successfully' });
      } else {
        callback(body);
      }
    } 
  });
};

Buttercoin.prototype.createOrder = function (params, timestamp, callback) {
  var url = this.buildUrl('orders');
  var signature = this.signUrl(url + JSON.stringify(params), timestamp);

  request.post({
    url: url,
    json: params,
    strictSSL: true,
    headers: this.getHeaders(signature, timestamp)
  }, function (err, res, body) {
    if (err) {
      callback(err);
    } else {
      if (res.statusCode === 202) {
        callback(null, { status: 202, order: res.headers.location });
      } else {
        callback(body);
      }
    } 
  });
};

Buttercoin.prototype.getTransactions = function (queryParams, timestamp, callback) {
  var url = this.buildUrl('transactions');
  var paramString = (queryParams && queryParams.length != 0) ? '' : "?" + qs.stringify(queryParams);
  var signature = this.signUrl(url + paramString, timestamp);

  request.get({
    url: url,
    qs: queryParams,
    json: true,
    strictSSL: true,
    headers: this.getHeaders(signature, timestamp)
  }, function (err, res, body) {
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

Buttercoin.prototype.getTransaction = function (trxnId, timestamp, callback) {
  var url = this.buildUrl('transactions/' + trxnId);
  var signature = this.signUrl(url, timestamp);

  request.get({
    url: url,
    json: true,
    strictSSL: true,
    headers: this.getHeaders(signature, timestamp)
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

Buttercoin.prototype.cancelTransaction = function (trxnId, timestamp, callback) {
  var url = this.buildUrl('transactions/' + trxnId);
  var signature = this.signUrl(url, timestamp);

  request.del({
    url: url,
    json: true,
    strictSSL: true,
    headers: this.getHeaders(signature, timestamp)
  }, function (err, res, body) {
    if (err) {
      callback(err);
    } else {
      if (res.statusCode === 204) {
        callback(null, { status: 204, message: 'Transaction canceled successfully' });
      } else {
        callback(body);
      }
    } 
  });
};

Buttercoin.prototype.createDeposit = function (params, timestamp, callback) {
  var url = this.buildUrl('transactions/deposit');
  var signature = this.signUrl(url + JSON.stringify(params), timestamp);

  request.post({
    url: url,
    json: params,
    strictSSL: true,
    headers: this.getHeaders(signature, timestamp)
  }, function (err, res, body) {
    if (err) {
      callback(err);
    } else {
      if (res.statusCode === 202) {
        callback(null, { status: 202, transaction: res.headers.location });
      } else {
        callback(body);
      }
    } 
  });
};

Buttercoin.prototype.createWithdrawal = function (params, timestamp, callback) {
  var url = this.buildUrl('transactions/withdrawal');
  var signature = this.signUrl(url + JSON.stringify(params), timestamp);

  request.post({
    url: url,
    json: params,
    strictSSL: true,
    headers: this.getHeaders(signature, timestamp)
  }, function (err, res, body) {
    if (err) {
      callback(err);
    } else {
      if (res.statusCode === 201) {
        callback(null, { status: 201, message: 'Withdraw request created, but email confirmation is required' });
      } else if (res.statusCode === 202) {
        callback(null, { status: 202, transaction: res.headers.location });
      } else {
        callback(body);
      }
    } 
  });
};

Buttercoin.prototype.send = function (params, timestamp, callback) {
  var url = this.buildUrl('transactions/send');
  var signature = this.signUrl(url + JSON.stringify(params), timestamp);

  request.post({
    url: url,
    json: params,
    strictSSL: true,
    headers: this.getHeaders(signature, timestamp)
  }, function (err, res, body) {
    if (err) {
      callback(err);
    } else {
      if (res.statusCode === 201) {
        callback(null, { status: 'Send request created, but email confirmation is required' });
      } else if (res.statusCode === 202) {
        callback(null, { transaction: res.headers.location });
      } else {
        callback(body);
      }
    } 
  });
};

Buttercoin.prototype.getOrderbook = function (timestamp, callback) {
  var url = this.buildUrl('orderbook');
  var signature = this.signUrl(url, timestamp);

  request.get({
    url: url,
    json: true,
    strictSSL: true,
    headers: this.getHeaders(signature, timestamp)
  }, function (err, res, body) {
    if (err) {
      callback(err);
    } else {
      if (res.statusCode === 200) {
	callback(null, body.market);
      } else {
        callback(body);
      }
    } 
  });
};

Buttercoin.prototype.getTicker = function (timestamp, callback) {
  var url = this.buildUrl('ticker');
  var signature = this.signUrl(url, timestamp);

  request.get({
    url: url,
    json: true,
    strictSSL: true,
    headers: this.getHeaders(signature, timestamp)
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
