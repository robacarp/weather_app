require "net/http"

# A minimal wrapper around the weatherapi.com API.
#
# Example:
#
#  api = WeatherApi.new(ENV["WEATHER_API_KEY"])
#  weather = api.fetch_weather("London")
#  => WeatherApi::Response
#
#  # Get the location understood by the API:
#  weather.location.name # => "London"
#
#  # Get the current temperature (in fahrenheit) at the location:
#  weather.conditions.temperature # => 80
#
#  # Get an icon representing the current weather condition:
#  weather.conditions.icon # => "//cdn.weatherapi.com/weather/64x64/day/116.png"
#
#  # Get the forecast for the next 3 days:
#  weather.forecast
#  => [WeatherApi::Forecast ...]
class WeatherApi
  # Raised when the WeatherAPI returns an error for a query.
  class LocationNotFound < StandardError
  end

  # Raised when the WeatherAPI call fails or the response cannot be parsed.
  class Error < StandardError
  end

  # @param api_key [String] the WeatherAPI secret key to use for requests.
  def initialize(api_key)
    @api_key = api_key
  end

  # Fetch a weather conditions and forecast for a location.
  # @param location [String] the location to fetch the weather for. The WeatherAPI takes care of geocoding, so this 
  #   can be a zip code, city name, etc.
  # @return [WeatherApi::Response] the weather conditions and forecast for the location.
  def fetch_weather(location)
    from_cache = true

    response = cache_fetch location do 
      from_cache = false
      request("https://api.weatherapi.com/v1/forecast.json", q: location, days: 3, aqi: "no", alerts: "no")
    end

    if response["error"]
      raise LocationNotFound, "WeatherAPI error: #{response["error"]["message"]}"
    end

    WeatherApi::Response.new response, from_cache: from_cache
  end

  private

  # A general wrapper around the Rails cache, which logs cache misses.
  #
  # Scraping the logs to monitor the count of CACHEMISSes as a percentage of requests is recommended.
  def cache_fetch(key)
    Rails.cache.fetch([:weather_api, key], expires_in: 30.minutes) do
      Rails.logger.info "WeatherAPI CACHEMISS for '#{key}'"

      if Rails.env.development?
        Rails.logger.warn "\033[34mCaching is disabled in development by default in rails.\033[0m"
        Rails.logger.info "Run `rails dev:cache` to enable caching in development."
      end

      yield
    end
  end

  # Make a request to the WeatherAPI.
  #
  # @param url [String] the api endpoint to query.
  # @param params [Hash] the query parameters to include in the request.
  #
  # @return [Hash] the parsed JSON response from the WeatherAPI.
  # @raise [Error] if the response is not valid JSON, or if the HTTP request fails due to network issues.
  def request(url, params = {})
    params[:key] = @api_key
    uri = URI(url)
    uri.query = URI.encode_www_form params
    http = Net::HTTP.new uri.host, uri.port
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    request = Net::HTTP::Get.new uri
    response = http.request request

    JSON.parse response.body
  rescue e
    raise Error, "WeatherAPI request failed: #{e.class} #{e.message}"
  end
end
