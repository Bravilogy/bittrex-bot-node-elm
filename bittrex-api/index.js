const future = require('fluture');
const moment = require('moment');

const {
  lt,
  map,
  prop,
  path,
  both,
  pipe,
  props,
  propEq,
  filter,
  concat,
  compose,
  traverse,
  complement,
} = require('ramda');

const Bittrex = require('./wrapper');

const bittrex = new Bittrex(
  process.env.API_KEY,
  process.env.API_SECRET,
);

const BALANCE_MINIMUM = 0.00001;

const shouldHaveSomeBalance = compose(lt(BALANCE_MINIMUM), prop('Available'));
const shouldNotBeBTC = complement(propEq('Currency', 'BTC'));

const formatAvailableBalances = pipe(
  filter(both(shouldHaveSomeBalance, shouldNotBeBTC)),
  map(compose(concat('BTC-'), prop('Currency'))),
);

const getOrderHistory = market =>
  future((reject, resolve) =>
    void bittrex.accountGetOrderHistory(market)
    .then(resolve).catch(reject))
  .map(path(['result', 0]));

const getOpenOrders = future((reject, resolve) =>
    void bittrex.marketGetOpenOrders()
    .then(resolve).catch(reject))
  .map(prop('result'));

const getTicker = market =>
  future((reject, resolve) =>
    void bittrex.publicGetTicker(market)
    .then(resolve).catch(reject))
  .map(prop('result'));

const mergeOpenOrderWithCurrentPrice = order =>
  getTicker(order.Exchange)
  .map(result => ({
    ...order,
    Opened: moment(order.Opened).fromNow(),
    Price: result.Last,
  }));

const getOpenOrdersWithCurrentPrices = getOpenOrders
  .chain(traverse(future.of, mergeOpenOrderWithCurrentPrice));

const getAccountBalances = future((reject, resolve) =>
    void bittrex.accountGetBalances()
    .then(resolve).catch(reject))
  .map(prop('result'))
  .map(formatAvailableBalances)
  .chain(traverse(future.of, getOrderHistory));

const mergeBalanceWithCurrentPrice = balance =>
  getTicker(balance.Exchange)
  .map(result => ({
    ...balance,
    CurrentPrice: result.Last,
  }));

const getAccountBalancesWithCurrentPrices = getAccountBalances
  .chain(traverse(future.of, mergeBalanceWithCurrentPrice));

module.exports = {
  getOpenOrdersWithCurrentPrices,
  getAccountBalancesWithCurrentPrices,
};
