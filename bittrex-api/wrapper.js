const https       = require('https');
const crypto      = require('crypto');
const querystring = require('querystring');

const isJson = (str) => {
  try {
    JSON.parse(str);
  } catch (e) {
    return false;
  }
  return true;
};

const request = (opts, data = null) =>
  new Promise((resolve, reject) => {
    try {
      let _opts = JSON.parse(JSON.stringify(opts));
      if (_opts.method.toUpperCase() === 'GET' && data) {
        _opts = Object.assign({}, _opts, { path: `${_opts.path}?${querystring.stringify(data)}` });
      }
      const req = https.request(_opts, (res) => {
        let str = '';
        res.on('data', (chunk) => {
          str += chunk;
        });
        res.on('end', () => {
          resolve(isJson(str) ? JSON.parse(str) : str);
        });
        res.on('error', (e) => {
          reject(e);
        });
      });
      if ((_opts.method.toUpperCase() === 'PUT' || _opts.method.toUpperCase() === 'POST') && data) {
        if (_opts.headers && (_opts.headers['Content-Type'] === 'application/json' || _opts.headers['content-type'] === 'application/json')) {
          req.write(JSON.stringify(data));
        } else {
          req.write(querystring.stringify(data));
        }
      }
      req.end();
    } catch (err) {
      reject(err);
    }
  });

class Bittrex {
  constructor(apiKey = null, apiSecret = null, apiProtocol = 'https', apiHost = 'bittrex.com', apiVersion = 'v1.1') {
    this.__lastNonce = null;
    this.__apiProtocol = apiProtocol;
    this.__apiHost = apiHost;
    this.__apiVersion = apiVersion;
    this.__apiKey = apiKey;
    this.__apiSecret = apiSecret;

    // Public endpoints
    this.PUBLIC_GET_MARKETS = '/public/getmarkets';
    this.PUBLIC_GET_CURRENCIES = '/public/getcurrencies';
    this.PUBLIC_GET_TICKER = '/public/getticker';
    this.PUBLIC_GET_MARKET_SUMMARIES = '/public/getmarketsummaries';
    this.PUBLIC_GET_MARKET_SUMMARY = '/public/getmarketsummary';
    this.PUBLIC_GET_ORDER_BOOK = '/public/getorderbook';
    this.PUBLIC_GET_MARKET_HISTORY = '/public/getmarkethistory';

    // Market endpoints
    this.MARKET_BUY_LIMIT = '/market/buylimit';
    this.MARKET_SELL_LIMIT = '/market/selllimit';
    this.MARKET_CANCEL = '/market/cancel';
    this.MARKET_GET_OPEN_ORDERS = '/market/getopenorders';

    // Account endpoints
    this.ACCOUNT_GET_BALANCES = '/account/getbalances';
    this.ACCOUNT_GET_BALANCE = '/account/getbalance';
    this.ACCOUNT_GET_DEPOSIT_ADDRESS = '/account/getdepositaddress';
    this.ACCOUNT_WITHDRAW = '/account/withdraw';
    this.ACCOUNT_GET_ORDER = '/account/getorder';
    this.ACCOUNT_GET_ORDER_HISTORY = '/account/getorderhistory';
    this.ACCOUNT_GET_WITHDRAWAL_HISTORY = '/account/getwithdrawalhistory';
    this.ACCOUNT_GET_DEPOSIT_HISTORY = '/account/getdeposithistory';
  }

  getApiSign(uri) {
    const hmac = crypto.createHmac('sha512', this.__apiSecret);
    const signed = hmac.update(new Buffer(uri, 'utf-8')).digest('hex');
    return signed;
  }

  getNonce() {
    this.__lastNonce = Math.floor(new Date().getTime() / 1000);
    return this.__lastNonce;
  }

  doRequest(path, data) {
    return new Promise((resolve, reject) => {
      const _data = Object.assign(data || {}, this.__apiKey && this.__apiSecret ? {
        nonce: this.getNonce(),
        apikey: this.__apiKey
      } : {});
      const _url = `${this.__apiProtocol}://${this.__apiHost}/api/${this.__apiVersion}${path}?${querystring.stringify(_data)}`;
      const apisign = this.__apiKey && this.__apiSecret ? this.getApiSign(_url) : null;
      request({
        method: 'GET',
        host: this.__apiHost,
        path: `/api/${this.__apiVersion}${path}`,
        headers: apisign ? {
          apisign,
          'Content-Type': 'application/json'
        } : { 'Content-Type': 'application/json' }
      }, _data).then(res => resolve(res)).catch(err => reject(err));
    });
  }

  publicGetMarkets() {
    return this.doRequest(this.PUBLIC_GET_MARKETS);
  }

  publicGetCurrencies() {
    return this.doRequest(this.PUBLIC_GET_CURRENCIES);
  }

  publicGetTicker(market) {
    if (!market) {
      return Promise.reject(new Error('Market is required'));
    }
    return this.doRequest(this.PUBLIC_GET_TICKER, { market });
  }

  publicGetMarketSummaries() {
    return this.doRequest(this.PUBLIC_GET_MARKET_SUMMARIES);
  }

  publicGetMarketSummary(market) {
    if (!market) {
      return Promise.reject(new Error('Market is required'));
    }
    return this.doRequest(this.PUBLIC_GET_MARKET_SUMMARY, { market });
  }

  publicGetOrderBook(market, type = 'both', depth = 20) {
    if (!market) {
      return Promise.reject(new Error('Market is required'));
    }
    return this.doRequest(this.PUBLIC_GET_ORDER_BOOK, { market, type, depth });
  }

  publicGetMarketHistory(market) {
    if (!market) {
      return Promise.reject(new Error('Market is required'));
    }
    return this.doRequest(this.PUBLIC_GET_MARKET_HISTORY, { market });
  }

  marketBuyLimit(market, quantity, rate) {
    if (!this.__apiKey) {
      return Promise.reject(new Error('API key is required for market requests'));
    }
    if (!this.__apiSecret) {
      return Promise.reject(new Error('API secret is required for market requests'));
    }
    if (!market) {
      return Promise.reject(new Error('Market is required'));
    }
    if (!quantity) {
      return Promise.reject(new Error('Quantity is required'));
    }
    if (!rate) {
      return Promise.reject(new Error('Rate is required'));
    }
    return this.doRequest(this.MARKET_BUY_LIMIT, { market, quantity, rate });
  }

  marketSellLimit(market, quantity, rate) {
    if (!this.__apiKey) {
      return Promise.reject(new Error('API key is required for market requests'));
    }
    if (!this.__apiSecret) {
      return Promise.reject(new Error('API secret is required for market requests'));
    }
    if (!market) {
      return Promise.reject(new Error('Market is required'));
    }
    if (!quantity) {
      return Promise.reject(new Error('Quantity is required'));
    }
    if (!rate) {
      return Promise.reject(new Error('Rate is required'));
    }
    return this.doRequest(this.MARKET_SELL_LIMIT, { market, quantity, rate });
  }

  marketCancel(uuid) {
    if (!this.__apiKey) {
      return Promise.reject(new Error('API key is required for market requests'));
    }
    if (!this.__apiSecret) {
      return Promise.reject(new Error('API secret is required for market requests'));
    }
    if (!uuid) {
      return Promise.reject(new Error('UUID is required'));
    }
    return this.doRequest(this.MARKET_CANCEL, { uuid });
  }

  marketGetOpenOrders(market) {
    if (!this.__apiKey) {
      return Promise.reject(new Error('API key is required for market requests'));
    }
    if (!this.__apiSecret) {
      return Promise.reject(new Error('API secret is required for market requests'));
    }
    return this.doRequest(this.MARKET_GET_OPEN_ORDERS, { market });
  }

  accountGetBalances() {
    if (!this.__apiKey) {
      return Promise.reject(new Error('API key is required for account requests'));
    }
    if (!this.__apiSecret) {
      return Promise.reject(new Error('API secret is required for account requests'));
    }
    return this.doRequest(this.ACCOUNT_GET_BALANCES);
  }

  accountGetBalance(currency) {
    if (!this.__apiKey) {
      return Promise.reject(new Error('API key is required for account requests'));
    }
    if (!this.__apiSecret) {
      return Promise.reject(new Error('API secret is required for account requests'));
    }
    if (!currency) {
      return Promise.reject(new Error('Currency is required'));
    }
    return this.doRequest(this.ACCOUNT_GET_BALANCE, { currency });
  }

  accountGetDepositAddress(currency) {
    if (!this.__apiKey) {
      return Promise.reject(new Error('API key is required for account requests'));
    }
    if (!this.__apiSecret) {
      return Promise.reject(new Error('API secret is required for account requests'));
    }
    if (!currency) {
      return Promise.reject(new Error('Currency is required'));
    }
    return this.doRequest(this.ACCOUNT_GET_DEPOSIT_ADDRESS, { currency });
  }

  accountWithdraw(currency, quantity, address, paymentid = null) {
    if (!this.__apiKey) {
      return Promise.reject(new Error('API key is required for account requests'));
    }
    if (!this.__apiSecret) {
      return Promise.reject(new Error('API secret is required for account requests'));
    }
    if (!currency) {
      return Promise.reject(new Error('Currency is required'));
    }
    if (!quantity) {
      return Promise.reject(new Error('Quantity is required'));
    }
    if (!address) {
      return Promise.reject(new Error('Address is required'));
    }
    return this.doRequest(this.ACCOUNT_WITHDRAW, { currency, quantity, address, paymentid });
  }

  accountGetOrder(uuid) {
    if (!this.__apiKey) {
      return Promise.reject(new Error('API key is required for account requests'));
    }
    if (!this.__apiSecret) {
      return Promise.reject(new Error('API secret is required for account requests'));
    }
    if (!uuid) {
      return Promise.reject(new Error('UUID is required'));
    }
    return this.doRequest(this.ACCOUNT_GET_ORDER, { uuid });
  }

  accountGetOrderHistory(market) {
    if (!this.__apiKey) {
      return Promise.reject(new Error('API key is required for account requests'));
    }
    if (!this.__apiSecret) {
      return Promise.reject(new Error('API secret is required for account requests'));
    }
    return this.doRequest(this.ACCOUNT_GET_ORDER_HISTORY, { market });
  }

  accountGetWithdrawalHistory(currency) {
    if (!this.__apiKey) {
      return Promise.reject(new Error('API key is required for account requests'));
    }
    if (!this.__apiSecret) {
      return Promise.reject(new Error('API secret is required for account requests'));
    }
    return this.doRequest(this.ACCOUNT_GET_WITHDRAWAL_HISTORY, { currency });
  }

  accountGetDepositHistory(currency) {
    if (!this.__apiKey) {
      return Promise.reject(new Error('API key is required for account requests'));
    }
    if (!this.__apiSecret) {
      return Promise.reject(new Error('API secret is required for account requests'));
    }
    return this.doRequest(this.ACCOUNT_GET_DEPOSIT_HISTORY, { currency });
  }
}

module.exports = Bittrex;
