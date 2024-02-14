# Weather Demo API project

# Summary

This project uses the weather api from [WeatherAPI](https://www.weatherapi.com/) to retrieve conditions and forecast data based on user provided location. The location geocoding is handled by WeatherAPI. Results are cached in Redis. I used a default Rails 7 installation, with no database. Tailwindcss-rails is used to simplify styling.

Tests can be run with `bin/test`.

# Assignment

Guidelines for this project were as follows.

Requirements:
 - Must be done in Ruby on Rails
 - Accept an address as input
 - Retrieve forecast data for the given address. This should include, at minimum, the current temperature (Bonus points - Retrieve high/low and/or extended forecast)
 - Display the requested forecast details to the user
 - Cache the forecast details for 30 minutes for all subsequent requests by zip codes. Display indicator if result is pulled from cache.

Assumptions:
 - This project is open to interpretation
 - Functionality is a priority over form
 - If you get stuck, complete as much as you can

Submission:
 - Use a public source code repository (GitHub, etc) to store your code
 - Send us the link to your completed code

# Running the project:

## Prerequisites:

- Docker desktop installed
- A WeatherAPI key, available from [https://www.weatherapi.com/my/](https://www.weatherapi.com/my/). Accounts are free.

## Boot Up:

- Clone the repo
- `cp .env.example .env` and fill in your WeatherAPI key.
- Run `bin/dev` in the root directory.
- Visit [http://localhost:3000](http://localhost:3000)

## Caching:

- Rails caching is disabled in development by default. Caching for development is enabled with the `rails dev:cache` command.
- This project is setup to use Redis for caching, and the docker-compose includes a redis container. To manually flush the cache, run `/bin/flushcache`

## Documentation:

This assignment has been documented using YARD. Run `bin/docs` to generate documentation, and open `doc/index.html`.

## Tests:

To run the tests within docker, use `bin/test`.
