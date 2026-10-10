from flask import Flask, render_template, request, jsonify
import requests
import os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)

API_KEY = os.getenv("OPENWEATHER_API_KEY")


@app.route("/")
def home():
    return render_template("index.html")


@app.route("/weather")
def weather():
    city = request.args.get("city")

    if not city or not city.strip():
        return jsonify({"error": "City is required"}), 400

    api_key = os.getenv("OPENWEATHER_API_KEY") or API_KEY
    if not api_key:
        return jsonify({"error": "API key is not configured on the server"}), 500

    url = "https://api.openweathermap.org/data/2.5/weather"

    params = {
        "q": city.strip(),
        "appid": api_key,
        "units": "metric"
    }

    try:
        response = requests.get(url, params=params, timeout=10)
    except requests.exceptions.RequestException:
        return jsonify({"error": "Failed to connect to weather service"}), 502

    if response.status_code != 200:
        error_msg = "City not found"
        try:
            error_data = response.json()
            if "message" in error_data:
                error_msg = error_data["message"]
        except Exception:
            pass
        return jsonify({"error": error_msg.capitalize()}), response.status_code

    data = response.json()

    weather_data = {
        "city": data.get("name", city.strip()),
        "country": data.get("sys", {}).get("country", ""),
        "temperature": data.get("main", {}).get("temp"),
        "feels_like": data.get("main", {}).get("feels_like"),
        "humidity": data.get("main", {}).get("humidity"),
        "wind_speed": data.get("wind", {}).get("speed"),
        "description": data.get("weather", [{}])[0].get("description", "")
    }

    return jsonify(weather_data)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)