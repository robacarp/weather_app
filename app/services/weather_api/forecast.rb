# Parses and provides access to forecast information from the WeatherAPI response.
#
# This represents a single day's forecast.
class WeatherApi::Forecast < Struct.new(:date, :high, :low, :chance_of_rain, :text, :icon)
  # @!attribute date
  #   the date of the forecast
  #   @return [Date]

  # @!attribute high
  #   the high temperature for the day
  #   @return [Float]
  #
  # @!attribute low
  #   the low temperature for the day
  #   @return [Float]
  #
  # @!attribute chance_of_rain
  #   the chance of rain as a percentage
  #   @return [Integer]
  #
  # @!attribute text
  #   a descriptive text for the weather condition
  #   @return [String]
  #
  # @!attribute icon
  #   a URL to an icon representing the weather condition
  #   @return [String]

  # Parses a single forecast day from the WeatherAPI response.
  def self.from_response_forecast_day(forecast_day_json)
    day = forecast_day_json["day"]
    new(
      Date.parse(forecast_day_json["date"]),
      day["maxtemp_f"],
      day["mintemp_f"],
      day["daily_chance_of_rain"],
      day["condition"]["text"],
      day["condition"]["icon"]
    )
  end
end
