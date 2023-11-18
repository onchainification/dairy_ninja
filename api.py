from fastapi import FastAPI

app = FastAPI()


@app.get("/")
async def root():
    # TODO: this needs to be implemented into deployment pipeline
    # import subprocess
    # hash = (
    #     subprocess.check_output(["git", "rev-parse", "--short", "HEAD"])
    #     .decode("ascii")
    #     .strip()
    # )
    # return {"message": "SmartGarden API", "latest_commit": hash}
    return {"message": "SmartGarden API"}
