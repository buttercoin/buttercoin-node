node-buttercoin
===============

Official Node Client of the Buttercoin API.  Buttercoin is a trading platform that makes buying and selling bitcoin easy.

## Getting Started

Use npm to install

```javascript
npm install node-buttercoin
```

## Examples

### Initialization

```javascript
// Configure Buttercoin instance.  Only apiKey and apiSecret are required.

// The mode parameter defaults to the development staging environment.
// For live data, send 'production' to the mode parameter.

// The version parameter defaults to the latest version as of this release, 'v1'

var buttercoin = require('node-buttercoin')('<api_key>', '<api_secret>', '<mode>', '<version>');
```

**Tips**

A note on the `timestamp` param sent to all client methods:
This param must always be increasing, and within 5 minutes of Buttercoin server times (GMT). This is to prevent replay attacks on your data.

Because of this, if you need your API calls to run in a certain order, you must chain together callbacks to ensure synchronous responses to your requests.

```
var timestamp = new Date().getTime();
```

### Get Data

**Key Permissions**  
Returns `array` of permissions associated with this key

```javascript
buttercoin.getKey(new Date().getTime(), function (err, key) {
  console.log("key err", err);
  console.log("key", key);
});
```

**Deposit Address**  
Returns bitcoin address `string` to deposit your funds into the Buttercoin platform

```javascript
buttercoin.getDepositAddress(new Date().getTime(), function (err, address) {
  console.log("address err", err);
  console.log("address", address);
});
```

**Get Orders**  
Returns `array` of `JSON Objects` containing information about buy and sell orders

Valid params include:  
`status` - enum: `['open', 'reopened', 'filled', 'canceled']`  
`dateMin` - format: ISO-8601, e.g. `'2014-05-06T13:15:30Z'`  
`dateMax` - format: ISO-8601, e.g. `'2014-05-06T13:15:30Z'`  
`side` - enum: `['buy', 'sell']`  
`orderType` - enum: `['market', 'limit']`  
`page` - number of page requested, `integer`  
`pageSize` - size of page requested, `integer`  

```javascript
// query for multiple orders
var orderParams = { orderAction: 'sell' };

buttercoin.getOrders(orderParams, new Date().getTime(), function (err, orders) {
  console.log("orders err", err);
  console.log("orders", orders);
});

// single order by id
var orderId = '<order_id>';

buttercoin.getOrder(orderId, new Date().getTime(), function (err, orders) {
  console.log("order err", err);
  console.log("single order", orders);
});
```

**Get Transaction**  
Returns `array` of `JSON Objects` containing information about deposit and withdraw action

Valid params include:  
`status` - enum: `['pending', 'processing', 'funded', 'canceled', 'failed']`  
`dateMin`  - format: ISO-8601, e.g. `'2014-05-06T13:15:30Z'`  
`dateMax` - format: ISO-8601, e.g. `'2014-05-06T13:15:30Z'`  
`transactionType` - enum: `['deposit', 'withdrawal']`  
`page` - number of page requested, `integer`  
`pageSize` - size of page requested, `integer`  

```javascript
// query for multiple transactions
var trxnParams = {};

buttercoin.getTransactions(trxnParams, new Date().getTime(), function (err, orders) {
  console.log("trxn err", err);
  console.log("trxn", orders);
});

var trxnId = '53a22ce164f23e7301a4fee5';

buttercoin.getTransaction(trxnId, new Date().getTime(), function (err, transaction) {
  console.log("single trxn err", err);
  console.log("single trxn", transaction);
});
```

**Get Order Book**  
Return an `array` of current orders in the Buttercoin order book

```javascript
buttercoin.getOrderbook(new Date().getTime(), function (err, orderBook) {
  console.log("order book err", err);
  console.log("order book", orderBook);
});
```

**Get Ticker**  
Return the current bid, ask, and last sell prices on the Buttercoin platform

```javascript
buttercoin.getTicker(new Date().getTime(), function (err, orderBook) {
  console.log("order book err", err);
  console.log("order book", orderBook);
});
```

### Create New Actions

**Create Order**  

Valid order params include:
`instrument` - enum: `['BTC_USD, USD_BTC']`
`side` - enum: `['buy', 'sell']`, required `true`  
`orderType` - enum: `['limit', 'market']`, required `true`  
`price` - e.g. `600.11`, required `false`  
`quantity` - e.g. `1.121`, required `false`

```javascript
// create a JSON object with the following params
var order = {
  instrument: "BTC_USD",
  orderAction: "buy",
  orderType: "limit",
  price: "700.00"
  quantity: "5"
};

buttercoin.createOrder(order, new Date().getTime(), function (err, order) {
  console.log("create order err", err);
  console.log("create order", order);
});
```

**Create Transaction**  

Deposit transaction params include:  
`method` - enum: `['wire']`, required `true`  
`currency` - enum: `['USD']`, required `true`  
`amount` - `float`, required true  

```javascript
// create deposit
var trxnObj = {
  method: "wire",
  currency: "USD",
  amount: "5002"
};

buttercoin.createDeposit(trxnObj, new Date().getTime(), function (err, trxn) {
  console.log("create trxn err", err);
  console.log("create trxn", trxn);
});
```

Withdrawal transaction params include:  
`method` - enum: `['wire']`, required `true`  
`currency` - enum: `['USD']`, required `true`  
`amount` - `float`, required true  

```javascript
// create withdrawal
var trxnObj = {
  method: "check",
  currency: "USD",
  amount: "100"
};

buttercoin.createWithdrawal(trxnObj, new Date().getTime(), function (err, trxn) {
  console.log("create trxn err", err);
  console.log("create trxn", trxn);
});
```
Send bitcoin transaction params include:  
`method` - enum: `['wire']`, required `true`  
`currency` - enum: `['USD']`, required `true`  
`destination` - address to which to send currency `string`, required true  

```javascript
// send bitcoins to an address
var trxnObj = {
  currency: "BTC",
  amount: "100.231231",
  destination: "<bitcoin_address>"
};

buttercoin.send(trxnObj, new Date().getTime(), function (err, trxn) {
  console.log("create trxn err", err);
  console.log("create trxn", trxn);
});
```


### Cancel Actions

All successful cancel calls to the API return a response status of `204` with a human readable success message

**Cancel Order**  
Cancel a pending buy or sell order

```javascript
buttercoin.cancelOrder(orderId, new Date().getTime(), function (err, msg) {
  console.log("cancel order err", err);
  console.log("cancel order", msg);
});
```

**Cancel Transaction**  
Cancel a pending deposit or withdraw action

```javascript
buttercoin.cancelTransaction(trxnId, new Date().getTime(), function (err, msg) {
  console.log("cancel trxn err", err);
  console.log("cancel trxn", msg);
});
```

## Further Reading

[Buttercoin - Website](https://www.buttercoin.com)  
[Buttercoin API Docs](https://www.buttercoin.com/#/api-docs)

## Contributing

This is an open source project and we love involvement from the community! Hit us up with pull requests and issues. 

The aim is to take your great ideas and make everyone's experience using Buttercoin even more powerful. The more contributions the better!

## Release History

### 0.0.1

- First release.

## License

Licensed under the MIT license.

