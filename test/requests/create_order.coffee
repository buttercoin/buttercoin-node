CreateOrder = require('../../lib/requests/create_order')

describe 'CreateOrder', ->
  describe 'Helpers', ->
    it 'should have a helper for market bids', ->
      order = CreateOrder::marketBid(100)
      order.instrument.should.equal 'USD_BTC'
      order.side.should.equal 'sell'
      order.orderType.should.equal 'market'
      order.quantity.should.equal 100

    it 'should have a helper for market asks', ->
      order = CreateOrder::marketAsk(100)
      order.instrument.should.equal 'BTC_USD'
      order.side.should.equal 'sell'
      order.orderType.should.equal 'market'
      order.quantity.should.equal 100

    it 'should have a helper for limit bids', ->
      order = CreateOrder::limitBid(price: 100, quantity: 10)
      order.instrument.should.equal 'BTC_USD'
      order.side.should.equal 'buy'
      order.orderType.should.equal 'limit'
      order.price.should.equal 100
      order.quantity.should.equal 10

    it 'should have a helper for limit asks', ->
      order = CreateOrder::limitAsk(price: 200, quantity: 10)
      order.instrument.should.equal 'BTC_USD'
      order.side.should.equal 'sell'
      order.orderType.should.equal 'limit'
      order.price.should.equal 200
      order.quantity.should.equal 10

  describe 'Initialization', ->
    it 'should fail on missing arguments', ->
      (-> new CreateOrder(side: 'buy', orderType: 'market', quantity: 100)).should.throw(
        'Invalid instrument: undefined')
      (-> new CreateOrder(instrument: 'USDBTC', side: 'buy', orderType: 'market', quantity: 100)).should.throw(
        'Invalid instrument: USDBTC')
      (-> new CreateOrder(instrument: 'USD_BTC', orderType: 'market', quantity: 100)).should.throw(
        'Invalid side: undefined')
      (-> new CreateOrder(instrument: 'USD_BTC', side: 'bid', orderType: 'market', quantity: 100)).should.throw(
        'Invalid side: bid')
      (-> new CreateOrder(instrument: 'USD_BTC', side: 'buy', quantity: 100)).should.throw(
        'Invalid orderType: undefined')
      (-> new CreateOrder(instrument: 'USD_BTC', side: 'buy', orderType: 'MARKET', quantity: 100)).should.throw(
        'Invalid orderType: MARKET')
      (-> new CreateOrder(instrument: 'USD_BTC', side: 'buy', orderType: 'market')).should.throw(
        'Invalid quantity: undefined')
      (-> new CreateOrder(instrument: 'USD_BTC', side: 'buy', orderType: 'market', quantity: -1)).should.throw(
        'Invalid quantity: -1')
      (-> new CreateOrder(instrument: 'USD_BTC', side: 'buy', orderType: 'limit', price: 1, quantity: -1)).should.throw(
        'Invalid quantity: -1')
      (-> new CreateOrder(instrument: 'USD_BTC', side: 'buy', orderType: 'limit', quantity: 1, price: -1)).should.throw(
        'Invalid price: -1')
