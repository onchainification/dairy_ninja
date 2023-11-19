# 🥷 DairyNinja

## API

deploys automatically to gcloud when committed to branch `main`.

url: https://api-playground-405417.ue.r.appspot.com/

### Step 1: compare 1inch vs cow using `get_quotes`

api endpoint retrieve quotes from both and returns a sorted list from high to low (`0` is 1inch, `1` is cow):

`GET`

`https://api-playground-405417.ue.r.appspot.com/get_quotes?sell_token_address=0xe91D153E0b41518A2Ce8Dd3D7944Fa863463a97d&sell_mantissa=10000000000000000&buy_token_address=0xcB444e90D8198415266c6a2724b7900fb12FC56E`

```
[
  [
    1,
    "9410094525775922"
  ],
  [
    0,
    "9150805270863836"
  ]
]
```

(ie `10000000000000000` worth of $wxdai yields `9410094525775922` $eure on cow and `9150805270863836` $eure on 1inch)

### Step 2: deploy airnode to read api endpoint onchain

the api endpoint from step 1 is deployed with id `awsed1d5d07`. also see [deployment log](airnode/logs/deployer-2023-11-19_03:23:45.log)
