import os

import requests
from fastapi import FastAPI


NULL_ADDRESS = "0x0000000000000000000000000000000000000000"


app = FastAPI()


@app.get("/")
async def root():
    return {"message": "Dairy Ninja API"}


@app.get("/get_quotes")
async def get_quotes(
    sell_token_address: str, sell_mantissa: str, buy_token_address: str
) -> list:
    async def get_fusion_quote(sell_token_address, sell_mantissa, buy_token_address):
        headers = {"Authorization": f"Bearer {os.getenv('FUSION_API_KEY')}"}
        chain = 100
        fusion_url = f"https://api.1inch.dev/swap/v5.2/{chain}/quote"
        params = {
            "src": sell_token_address,
            "dst": buy_token_address,
            "amount": sell_mantissa,
        }
        r = requests.get(fusion_url, headers=headers, params=params)
        r.raise_for_status()
        return r.json()["toAmount"]

    async def get_cow_quote(sell_token_address, sell_mantissa, buy_token_address):
        cow_url = "https://api.cow.fi/xdai/api/v1/quote"
        data = {
            "sellToken": sell_token_address,
            "buyToken": buy_token_address,
            "receiver": NULL_ADDRESS,
            "appData": '{"version":"0.1.0","metadata":{}}',
            "appDataHash": "0xdf63ff93b17690888041a5c4705b6208528f4600e0d9205d1f1280086ebf9967",
            "partiallyFillable": False,
            "sellTokenBalance": "erc20",
            "buyTokenBalance": "erc20",
            "from": NULL_ADDRESS,
            "priceQuality": "verified",
            "signingScheme": "eip712",
            "onchainOrder": False,
            "kind": "sell",
            "sellAmountBeforeFee": sell_mantissa,
        }
        r = requests.post(cow_url, json=data)
        r.raise_for_status()
        quote = r.json()["quote"]
        buy_amount = quote["buyAmount"]
        sell_amount = quote["sellAmount"]
        fee_amount = quote["feeAmount"]
        fee_factor = int(fee_amount) / int(sell_amount) + 1
        return str(int(int(buy_amount) * fee_factor))

    fusion = await get_fusion_quote(
        sell_token_address, sell_mantissa, buy_token_address
    )
    cow = await get_cow_quote(sell_token_address, sell_mantissa, buy_token_address)

    if fusion > cow:
        return [[0, fusion], [1, cow]]
    return [[1, cow], [0, fusion]]


# wxdai = 0xe91D153E0b41518A2Ce8Dd3D7944Fa863463a97d
# eure = 0xcB444e90D8198415266c6a2724b7900fb12FC56E
