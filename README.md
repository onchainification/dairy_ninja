# 🥷 DairyNinja

TL;DR: A multisig plugin that automatically decides which dex aggregator services to use based on API3 response, while not fully trusting the quotation of the services blindly by cross-checking with oracles services (Chronicle, API3) at the settlement time.

## Overview

At the present time, majority of dex aggregator are leveraging private infrastructure for quote provision, which does not necessarily mean they are neither legit nor precise as service can get corrupted. There should be an enforcement on-chain for the pricing, which ensures an healthy quotation within reasonable deviations.

Oracle health checks is achieved with a combination of oracles providers: Chronicle & API3. In light of neither trusting a single oracle entity, we are taking the maximum between the two (`max(oracle_a, oracle_b)`), which will be the value used for ensuring quotation legitimacy.

Assuming that health checks are satisfied a smart order will be executed automatically via CowSwap.

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

### Step 2:
