const future  = require('fluture');
const moment  = require('moment');

const {
  prop,
  compose,
  traverse,
} = require('ramda');

const Bittrex   = require('./wrapper');

const bittrex = new Bittrex(
  process.env.API_KEY,
  process.env.API_SECRET,
);

const getOpenOrders = future((reject, resolve) =>
  void bittrex.marketGetOpenOrders()
  .then(resolve).catch(reject))
    .map(prop('result'));

const getTicker = market =>
  future((reject, resolve) =>
    void bittrex.publicGetTicker(market)
    .then(resolve).catch(reject))
  .map(prop('result'));

const getOpenOrdersWithCurrentPrices = getOpenOrders
  .chain(traverse(future.of, order =>
    getTicker(order.Exchange)
      .map(result => ({
        ...order,
        Opened: moment(order.Opened).fromNow(),
        Price: result.Last,
      }))));

module.exports = {
  getOpenOrdersWithCurrentPrices,
};
