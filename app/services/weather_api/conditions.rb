# Parses and provides access to current conditions information from the WeatherAPI response.
class WeatherApi::Conditions < Struct.new(:temperature, :text, :icon)

  # @!attribute [rw] temperature
  #   The current "feels like" temperature in fahrenheit.
  #   @return [Float]

  # @!attribute text
  #   a descriptive text for the weather condition
  #   @return [String]

  # @!attribute icon 
  #   a URL to an icon representing the weather condition
  #   @return [String]

  def self.from_response(response_json)
    conditions = response_json["current"]
    new(
      conditions["feelslike_f"],
      conditions["condition"]["text"],
      conditions["condition"]["icon"]
    )
  end
end
