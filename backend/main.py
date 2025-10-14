from fastapi import FastAPI, Query
import requests
import os
from dotenv import load_dotenv

load_dotenv()
app = FastAPI()

NEWS_API_KEY = os.getenv("NEWS_API_KEY")

@app.get("/headlines")
def get_headlines():
    url = f"https://newsapi.org/v2/everything?q=India&apiKey={NEWS_API_KEY}"
    #params = {"country": "us", "apiKey": NEWS_API_KEY}
    response = requests.get(url)
    return response.json()

@app.get("/search")
def search_headlines(q: str = Query(..., description="Search term for news")):
    url = "https://newsapi.org/v2/everything"
    params = {
        "q": q,
        "language": "en",
        "sortBy": "publishedAt",
        "apiKey": NEWS_API_KEY
    }
    response = requests.get(url, params=params)
    return response.json()
