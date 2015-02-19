Buttercoin API Node.js Client [![Build Status](https://travis-ci.org/buttercoin/buttercoin-node.svg?branch=master)](https://travis-ci.org/buttercoin/buttercoin-node)
=============================

Official Node.js Client of the Buttercoin API.  Buttercoin is a trading platform that makes buying and selling bitcoin easy.

## Getting Started

Use npm to install

```javascript
npm install buttercoin-node
```

## Examples

### Initialization

For authenticated requests, the API client must use either a key/secret pair or an OAuth2 bearer token.

#### Common

Setting | Property Name | Description
--- | --- | ---
Environment | `environment` | Your development environment (default: `'production'`, set to `'sandbox'` to test with testnet bitcoins). You can set this to an object with `host`, `protocol` (defaults to `'https'`), `port` (defaults to empty), and `headers` (defaults to `[]`) for custom endpoints.
API Version | `version` | The API Version.  Currently used to version the API URL and Service Description

#### Key/Secret

Setting | Property Name | Description
--- | --- | ---
Key | `key` | Your Buttercoin API Key
Secret | `secret` | Your Buttercoin API Secret

```javascript
// Configure Buttercoin client instance.  Only apiKey and apiSecret are required.
// The environment parameter defaults to the sandbox environment.
// The version parameter defaults to the latest version as of this release, 'v1'

var Buttercoin = require('buttercoin-node');
var API_KEY = // the Key ...
var API_SECRET = // the Secret ...
var env = Buttercoin.Environment.production;
var client = Buttercoin.withKeySecret(API_KEY, API_SECRET, environment, 'v1');
```

#### OAuth2

Setting | Property Name | Description
--- | --- | ---
Token Provider | `tokenProvider` | A function which take some credential evidence (e.g. a user session id) and maps it to a bearer token string

```javascript
// Only tokenProvider is required, environment and version default as above

var Buttercoin = require('buttercoin-node');
function tokenProvider(evidence) { /* lookup bearer tokens... */ }
var client = Buttercoin.withOAuth2(tokenProvider);
```

### Conventions

#### Promises

All API calls produce a [Q promise](https://github.com/kriskowal/q). We may support callback or event style interfaces if there's interest.

#### Timestamps

For the `timestamp` option sent to all key/secret client methods:
This option must always be increasing, and within 5 minutes of Buttercoin server times (GMT). This is to prevent replay attacks on your data.

Because of this, if you need your API calls to run in a certain order, you must chain together callbacks to ensure synchronous responses to your requests.

```javascript
var timestamp = new Date().getTime();
```

*Additionally, for convenience, if you don't include the timestamp option, it will default to the current time.*

```javascript
// API key/secret is configured on the client instance

// With explicit timestamp
client.getBalances({timestamp: new Date().getTime()});

// With automatic timestamp
client.getBalances()
  .then(/* do something ... */)
  .done();
```

#### Evidence
When using an OAuth2 client, you need to provide 'evidence' that can be used to derive a bearer token for a specific user.

Unlike in the case of timestamps, this must be passed to any method requiring authentication.

```javascript
var sessionId = // a user session ID which can be used to lookup a bearer token
client.getBalances(sessionId)
  .then(/* do something ... */)
  .done();
```

### Getting Data

**Credential Permissions**
Returns a promise for an `array` of permissions associated with this API key or bearer token.

```javascript
client.getPermissions();
```

**Balances**
Returns a promise for an `object`. Each key indicates a currency code (currently `'USD'` or `'BTC'`. Each associated value is a `number` representing the amount of that currency available.

```javascript
client.getBalances();
```

**Deposit Address**
Returns a promise for a bitcoin address `string` which can be used to deposit bitcoins into this account.

```javascript
client.getDepositAddress();
```

**Get Orders**
Returns `array` of `object`s containing information about buy and sell orders

Name | Param | Description
--- | --- | ---
Status | `status` | enum: `['opened', 'partial-filled', 'filled', 'canceled']`
Side | `side` | enum: `['buy', 'sell']`
Order Type | `orderType` | enum: `['market', 'limit']`
Date Min | `dateMin` | format: ISO-8601, e.g. `'2014-05-06T13:15:30Z'`
Date Max | `dateMax` | format: ISO-8601, e.g. `'2014-05-06T13:15:30Z'`

```javascript
// query for multiple orders
var orderParams = { side: 'sell' };
// the query parameter is optional and can be omitted for convenience to search all orders
client.getOrders(orderParams);

// single order by id
var orderId = '<order_id>';
client.getOrderById(orderId);

// single order by url
var url = '<url>';
client.getOrderByUrl(url);
```

**Get Transactions**
Returns `array` of `object`s containing information about deposits and withdrawals.

Name | Param | Description
--- | --- | ---
Status | `status` | enum: `['pending', 'processing', 'funded', 'canceled', 'failed']`
Transaction Type | `transactionType` | enum: `['deposit', 'withdrawal']`
Date Min | `dateMin` | format: ISO-8601, e.g. `'2014-05-06T13:15:30Z'`
Date Max | `dateMax` | format: ISO-8601, e.g. `'2014-05-06T13:15:30Z'`

```javascript
// query for multiple transactions
var txParams = {};
// the query parameter is optional and can be omitted for convenience to search all trxns
client.getTransactions(txParams);

// single transaction by id
var txId = '53a22ce164f23e7301a4fee5';
client.getTransaction(txId);

// single transaction by url
var url = 'https://api.buttercoin.com/v1/transactions/53e539aa64f23ec123931c11';
client.getTransaction(url);
```


###### Unauthenticated Requests

**Get Order Book**
Return an `array` of current orders in the Buttercoin order book

```javascript
client.getOrderbook();
```

**Get Ticker**
Return the current bid, ask, and last sell prices on the Buttercoin platform

```javascript
client.getTicker();
```

**Get Trade History**
Return the last 100 trades

```javascript
client.getTradeHistory();
```

### Create New Actions

*** Calls below this line are out of date ***
**Create Order**

Valid order params include:

Name | Param | Description
--- | --- | ---
Instrument | `instrument` | enum: `['BTC_USD, USD_BTC']`
Side | `side` | enum: `['buy', 'sell']`, required `true`
Order Type | `orderType` | enum: `['limit', 'market']`, required `true`
Price | `price` | `string`, required `false`
Quantity | `quantity` | `string`, required `false`

```javascript
// create a JSON object with the following params
var order = new client.Order({
  instrument: "BTC_USD",
  orderAction: "buy",
  orderType: "limit",
  price: "700.00"
  quantity: "5"
});

client.createOrder(order, new Date().getTime(), function (err, order) {
  console.log("create order err", err);
  console.log("create order", order);
});
```

**Create Transaction**

_Please contact Buttercoin support before creating a USD deposit using the API_

Deposit transaction params include:

Name | Param | Description
--- | --- | ---
Method | `method` | enum: `['wire']`, required `true`
Currency | `currency` | enum: `['USD']`, required `true`
Amount | `amount` | `string`, required `true`

```javascript
// create deposit
var trxnObj = {
  method: "wire",
  currency: "USD",
  amount: "5002"
};

client.createDeposit(trxnObj, new Date().getTime(), function (err, trxn) {
  console.log("create trxn err", err);
  console.log("create trxn", trxn);
});
```

Withdrawal transaction params include:

Name | Param | Description
--- | --- | ---
Method | `method` | enum: `['check']`, required `true`
Currency | `currency` | enum: `['USD']`, required `true`
Amount | `amount` | `string`, required `true`

```javascript
// create withdrawal
var trxnObj = {
  method: "check",
  currency: "USD",
  amount: "100"
};

client.createWithdrawal(trxnObj, new Date().getTime(), function (err, trxn) {
  console.log("create trxn err", err);
  console.log("create trxn", trxn);
});
```
Send bitcoin transaction params include:

Name | Param | Description
--- | --- | ---
Currency | `currency` | `['USD']`, required `true`
Amount | `amount` | `string`, required `true`
Destination | `destination` | address to which to send currency `string`, required `true`

```javascript
// send bitcoins to an address
var trxnObj = {
  currency: "BTC",
  amount: "100.231231",
  destination: "<bitcoin_address>"
};

client.sendBitcoin(trxnObj, new Date().getTime(), function (err, trxn) {
  console.log("create trxn err", err);
  console.log("create trxn", trxn);
});
```


### Cancel Actions

All successful cancel calls to the API return a response status of `204` with a human readable success message

**Cancel Order**
Cancel a pending buy or sell order

```javascript
client.cancelOrder(orderId, new Date().getTime(), function (err, msg) {
  console.log("cancel order err", err);
  console.log("cancel order", msg);
});
```

**Cancel Transaction**
Cancel a pending deposit or withdraw action

```javascript
client.cancelTransaction(trxnId, new Date().getTime(), function (err, msg) {
  console.log("cancel trxn err", err);
  console.log("cancel trxn", msg);
});
```

## Further Reading

[Buttercoin - Website](https://www.buttercoin.com)
[Buttercoin API Documentation](https://developer.buttercoin.com)

## Contributing

This is an open source project and we love involvement from the community. Hit us up with pull requests and issues.

## Release History

### 1.1.0
- Added support for using OAuth2 credentials
- Switched to returning promises instead of callback-passing
### 1.0.0
- Added the ability to connect to a custom endpoint instead of just staging or production

### Prereleases
- Added trade history endpoint
- Changed test env to sandbox.buttercoin.com
- Made timestamp an optional parameter (will default to current timestamp)
- Made getOrders and getTransactions query params optional
- Fixed issue with self not defined
- Fixed issue with orderbook returning null
- Added support for unauthenticated requests
- Fixed README format and accuracy
- First release.

## License

Licensed under the MIT license.

