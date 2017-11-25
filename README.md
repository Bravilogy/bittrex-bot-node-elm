# Bittrex info grabber

This little app will give you some useful information/updates around your cryptos on Bittrex.

It will show you the open orders you have, with potential earnings. It will also show you account balances and coins you have in #hodl state, along with their projected profits with today's price.

It is based on `Bittrex` api.

## How do I?

#### 1. Create an API key in your Bittrex account (read-only access recommended)
Even though this application doesn't change anything in your account, but rather gets information from it, it is sill recommended you give it just read-only access.
#### 2. Clone this repo
#### 3. Add `.env` file in the root:
It uses `dotenv` package and the `.env` file needs to be in the following format:
```
API_KEY=<your-api-key-here>
API_SECRET=<your-api-secret-here>
```
#### 4. Start node + webpack
`yarn start`

[http://localhost:3000](localhost:3000)
