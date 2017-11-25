const env = require('dotenv').config();
const bodyParser = require('body-parser');
const express = require('express');
const app = express();

const {
  getOpenOrdersWithCurrentPrices,
  getAccountBalancesWithCurrentPrices,
} = require('./bittrex-api');

const PORT = 8080;
const router = express.Router();

/* A few headers for restfulness */
app.use(bodyParser.urlencoded({
  extended: true,
}));

app.use(bodyParser.json());
app.use((req, res, next) => {
  res.setHeader('Access-Control-Allow-Origin', 'http://localhost:3000');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');
  res.setHeader('Access-Control-Allow-Header', 'X-Requested-With,content-type');

  next();
});

router.get('/open-orders', (req, res) => {
  getOpenOrdersWithCurrentPrices
    .fork(console.error, data => res.send({
      data,
    }));
});

router.get('/account-balances', (req, res) => {
  getAccountBalancesWithCurrentPrices
    .fork(console.error, data => res.send({
      data,
    }));
});

app.use('/api', router);

app.listen(PORT);
console.log('Connected on', PORT);
