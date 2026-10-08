async function getWeather() {

    const city =
        document
            .getElementById("cityInput")
            .value
            .trim();

    const message =
        document.getElementById("message");

    if (!city) {

        message.textContent =
            "Please enter a city name.";

        return;
    }

    message.textContent = "Loading...";

    try {

        const response =
            await fetch(
                `/weather?city=${encodeURIComponent(city)}`
            );

        const data =
            await response.json();

        if (!response.ok) {

            message.textContent =
                data.error;

            return;
        }

        document
            .getElementById("cityName")
            .textContent =
            `${data.city}, ${data.country}`;

        document
            .getElementById("temperature")
            .textContent =
            Math.round(data.temperature);

        document
            .getElementById("description")
            .textContent =
            data.description;

        document
            .getElementById("feelsLike")
            .textContent =
            Math.round(data.feels_like);

        document
            .getElementById("humidity")
            .textContent =
            data.humidity;

        document
            .getElementById("windSpeed")
            .textContent =
            data.wind_speed;

        message.textContent = "";

    } catch (error) {

        console.error(error);

        message.textContent =
            "Unable to connect to weather service.";
    }
}
