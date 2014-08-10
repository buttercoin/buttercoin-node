Buttercoin Node SDK Client
===============

Official Node Client of the Buttercoin API.  Buttercoin is a trading platform that makes buying and selling bitcoin easy.

## Getting Started

Use npm to install

```javascript
npm install buttercoinsdk-node
```

## Examples

### Initialization

Setting | Property Name | Description
--- | --- | ---
Public Key | `publicKey` | Your Buttercoin API Public Key  
Secret Key | `secretKey` | Your Buttercoin API Secret Key  
Environment | `environment` | Your development environment (default: `'production'`, set to `'staging'` to test with testnet bitcoins)
API Version | `version` | The API Version.  Currently used to version the API URL and Service Description

```javascript
// Configure Buttercoin instance.  Only apiKey and apiSecret are required.

// The environment parameter defaults to the 'production' environment.

// The version parameter defaults to the latest version as of this release, 'v1'

var client = require('buttercoinsdk-node')('<api_key>', '<api_secret>', '<environment>', '<version>');
```

**Tips**

A note on the `timestamp` param sent to all client methods:
This param must always be increasing, and within 5 minutes of Buttercoin server times (GMT). This is to prevent replay attacks on your data.

Because of this, if you need your API calls to run in a certain order, you must chain together callbacks to ensure synchronous responses to your requests.

```
var timestamp = new Date().getTime();
```

*Additionally, for convenience, if you don't include the timestamp parameter, it will default to the current timestamp.*

```
client.getKey(function (err, key) {
  // do something amazing!
});
```

### Get Data

**Key Permissions**  
Returns `array` of permissions associated with this key

```javascript
client.getKey(new Date().getTime(), function (err, key) {
  console.log("key err", err);
  console.log("key", key);
});
```

**Balances**  
Returns `array` of balances for this account

```javascript
client.getBalances(new Date().getTime(), function (err, balances) {
  console.log("balances err", err);
  console.log("balances", balances);
});
```

**Deposit Address**  
Returns bitcoin address `string` to deposit your funds into the Buttercoin platform

```javascript
client.getDepositAddress(new Date().getTime(), function (err, address) {
  console.log("address err", err);
  console.log("address", address);
});
```

**Get Orders**  
Returns `array` of `JSON Objects` containing information about buy and sell orders

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
client.getOrders(orderParams, new Date().getTime(), function (err, orders) {
  console.log("orders err", err);
  console.log("orders", orders);
});

// single order by id
var orderId = '<order_id>';

client.getOrderById(orderId, new Date().getTime(), function (err, orders) {
  console.log("order err", err);
  console.log("single order", orders);
});

// single order by url
var url = '<url>';

client.getOrderByUrl(url, new Date().getTime(), function (err, orders) {
  console.log("order err", err);
  console.log("single order", orders);
});
```

**Get Transactions**  
Returns `array` of `JSON Objects` containing information about deposit and withdraw action

Name | Param | Description
--- | --- | ---
Status | `status` | enum: `['pending', 'processing', 'funded', 'canceled', 'failed']`  
Transaction Type | `transactionType` | enum: `['deposit', 'withdrawal']`  
Date Min | `dateMin` | format: ISO-8601, e.g. `'2014-05-06T13:15:30Z'`  
Date Max | `dateMax` | format: ISO-8601, e.g. `'2014-05-06T13:15:30Z'`  

```javascript
// query for multiple transactions
var trxnParams = {};
// the query parameter is optional and can be omitted for convenience to search all trxns
client.getTransactions(trxnParams, new Date().getTime(), function (err, orders) {
  console.log("trxn err", err);
  console.log("trxn", orders);
});

// single transaction by id
var trxnId = '53a22ce164f23e7301a4fee5';

client.getTransaction(trxnId, new Date().getTime(), function (err, transaction) {
  console.log("single trxn err", err);
  console.log("single trxn", transaction);
});

// single transaction by url
var url = 'https://api.buttercoin.com/v1/transactions/53e539aa64f23ec123931c11';

client.getTransaction(url, new Date().getTime(), function (err, transaction) {
  console.log("single trxn err", err);
  console.log("single trxn", transaction);
});
```

###### Unauthenticated Requests

**Get Order Book**  
Return an `array` of current orders in the Buttercoin order book

```javascript
client.getOrderbook(function (err, orderBook) {
  console.log("order book err", err);
  console.log("order book", orderBook);
});
```

**Get Ticker**  
Return the current bid, ask, and last sell prices on the Buttercoin platform

```javascript
client.getTicker(function (err, ticker) {
  console.log("ticker err", err);
  console.log("ticker", ticker);
});
```

### Create New Actions

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
var order = {
  instrument: "BTC_USD",
  orderAction: "buy",
  orderType: "limit",
  price: "700.00"
  quantity: "5"
};

client.createOrder(order, new Date().getTime(), function (err, order) {
  console.log("create order err", err);
  console.log("create order", order);
});
```

**Create Transaction**  

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
[Buttercoin API Docs](https://developer.buttercoin.com)

## Contributing

This is an open source project and we love involvement from the community! Hit us up with pull requests and issues. 

The aim is to take your great ideas and make everyone's experience using Buttercoin even more powerful. The more contributions the better!

## Release History

### 0.0.1

- First release.

### 0.0.2

- Added support for unauthenticated requests
- Fixed README format and accuracy

### 0.0.3

- Fixed issue with orderbook returning null

### 0.0.4

- Fixed issue with self not defined

### 0.0.7

- Made timestamp an optional parameter (will default to current timestamp)
- Made getOrders and getTransactions query params optional

## License

Licensed under the MIT license.

