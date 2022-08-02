# ExWallet
ExWallet allows you to check the status of an `Ethereum transaction` from its hash.

The possible responses to a valid transaction hash are `success, failed and pending`.

<img width="868" alt="Screen Shot 2022-08-01 at 08 50 15" src="https://user-images.githubusercontent.com/10969968/182141801-582da309-0107-470b-872a-2afedf2225a2.png">

## How to use

### Build the project

Copy `.env-sample` to `.env`:

```
cp .env-sample .env
```

Open `.env` file and set value for environment variable `ETHERSCAN_API_KEY`:

> Note: click [here](https://docs.etherscan.io/getting-started/viewing-api-usage-statisticsg) to learn how create an API KEY

<img width="486" alt="Screen Shot 2022-08-02 at 13 33 23" src="https://user-images.githubusercontent.com/10969968/182426767-cdfc312c-3685-4dd6-b9d0-88ccb7cfd1df.png">


Build docker image:
```
docker-compose build
```

Create database for project:
```
docker-compose run api mix ecto.create
```

Up the project:
```
docker-compose up
```

The application will be available through
> http://localhost:4000

### Examples of transactions

`success transacation` example:
```
0x7b6d0e8d812873260291c3f8a9fa99a61721a033a01e5c5af3ceb5e1dc9e7bd0
```

`failed transacation` example:
```
0xb7636e1fe3db6a1851f58aef6c3b14280a954622dea9787bd2f972c298a44f14
```

`pending transacation`:
you can check for pending transactions in this [EtherScan pending transactions list](https://etherscan.io/txsPending)

## Running tests

To run tests, first we need to create the test database (needed only for first time):
```
docker-compose run api env MIX_ENV=test mix ecto.create
```

Then run tests using:
```
docker-compose run api env MIX_ENV=test mix test
```