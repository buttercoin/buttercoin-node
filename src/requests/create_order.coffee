class CreateOrder
  constructor: (options) ->
    @instrument = options.instrument
    @side = options.side
    @orderType = options.orderType

    unless ['USD_BTC', 'BTC_USD'].indexOf(@instrument) isnt -1
      throw new Error("Invalid instrument: #{@instrument}")

    unless ['buy', 'sell'].indexOf(@side) isnt -1
      throw new Error("Invalid side: #{@side}")

    if @orderType is 'limit'
      @price = options.price
      @quantity = options.quantity
      throw new Error("Invalid price: #{@price}") unless @price > 0
      throw new Error("Invalid quantity: #{@quantity}") unless @quantity > 0
    else if @orderType is 'market'
      @quantity = options.quantity
      throw new Error("Invalid quantity: #{@quantity}") unless @quantity > 0
    else
      throw new Error("Invalid orderType: #{@orderType}")

# Sell `amount` dollars for bitcoin at market price
CreateOrder.marketBid = (amount) ->
  new CreateOrder(
    instrument: 'USD_BTC'
    side: 'sell'
    orderType: 'market'
    quantity: amount)

# Sell `quantity` bitcoins at market price
CreateOrder.marketAsk = (quantity) ->
  new CreateOrder(
    instrument: 'BTC_USD'
    side: 'sell'
    orderType: 'market'
    quantity: quantity)

# Buy bitcoins at a specific price
CreateOrder.limitBid = (opts) ->
  {price: p, quantity: q} = opts
  new CreateOrder(
    instrument: 'BTC_USD'
    side: 'buy'
    orderType: 'limit'
    price: p
    quantity: q)

# Sell bitcoins at a specific price
CreateOrder.limitAsk = (opts) ->
  {price: p, quantity: q} = opts
  new CreateOrder(
    instrument: 'BTC_USD'
    side: 'sell'
    orderType: 'limit'
    price: p
    quantity: q)

module.exports = CreateOrder
