import os

import requests
from fastapi import FastAPI


NULL_ADDRESS = "0x0000000000000000000000000000000000000000"
FUSION_API_KEY = os.getenv("FUSION_API_KEY")
HEADERS = {"Authorization": f"Bearer {FUSION_API_KEY}"}
CHAIN = 100
FUSION_URL = f"https://api.1inch.dev/fusion/quoter/v1.0/{CHAIN}/quote/receive"

app = FastAPI()


@app.get("/")
async def root():
    return {"message": "Dairy Ninja API"}


@app.get("/get_quotes")
async def get_quotes(
    sell_token_address: str, sell_mantissa: str, buy_token_address: str
):
    params = {
        "fromTokenAddress": sell_token_address,
        "toTokenAddress": buy_token_address,
        "amount": sell_mantissa,
        "walletAddress": NULL_ADDRESS,
        "enableEstimate": "false",
        "isLedgerLive": "false",
    }
    r = requests.get(FUSION_URL, headers=HEADERS, params=params)
    r.raise_for_status()
    return r.json()["presets"]["fast"]["auctionEndAmount"]


# wxdai = 0xe91D153E0b41518A2Ce8Dd3D7944Fa863463a97d
# eure = 0xcB444e90D8198415266c6a2724b7900fb12FC56E
