# Parses and provides access to location information from the WeatherAPI response.
class WeatherApi::Location < Struct.new(:name, :latitude, :longitude)
  # @!attribute name
  #   the name of the location
  #   @return [String]
  # @!attribute latitude
  #   the latitude of the location
  #   @return [Float]
  # @!attribute longitude
  #   the longitude of the location
  #   @return [Float]

  # Parses location information from the WeatherAPI response.
  def self.from_response(response_json)
    location = response_json["location"]
    new(location["name"], location["lat"], location["lon"])
  end
end
