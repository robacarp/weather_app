# A response from the weather API with accessors for data convenience.
#
# Provides easy access to:
#
# - location: name, latitude and longitude
# - conditions: temperature, descriptive text and icon
# - daily forecasts:
#   - high and low temperatures
#   - chance of rain
#   - descriptive text and icon
#
# @see WeatherApi::Location
# @see WeatherApi::Conditions
# @see WeatherApi::Forecast
class WeatherApi::Response
  # Was the data fetched from local cache?
  def cached?
    @from_cache
  end

  # @private
  #
  # Build a response from the JSON returned by the API.
  #
  # @param response_json [Hash] the JSON response from the API.
  # @param from_cache [Boolean] was the data fetched from local cache?
  def initialize(response_json, from_cache:)
    @response_json = response_json
    @from_cache = from_cache
  end

  # Parse the location information returned from the API.
  #
  # see WeatherApi::Location
  def location
    WeatherApi::Location.from_response(@response_json)
  end

  # Parse the current conditions returned from the API.
  #
  # see WeatherApi::Conditions
  def conditions
    WeatherApi::Conditions.from_response(@response_json)
  end

  # Parse the daily forecasts returned from the API.
  #
  # @see WeatherApi::Forecast
  def daily_forecasts
    @response_json["forecast"]["forecastday"].map do |day|
      WeatherApi::Forecast.from_response_forecast_day(day)
    end
  end

  # Last update time in a Time object.
  #
  # Not all locations have up-to-the-minute data, and the WeatherAPI
  # caches lookups as well.
  def as_of
    Time.parse @response_json["current"]["last_updated"]
  end

  # @private
  # For debugging purposes.
  def inspect
    "#<WeatherApi::Response #{location.name} #{conditions.temperature} #{as_of}>"
  end
end
