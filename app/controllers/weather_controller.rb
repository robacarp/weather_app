class WeatherController < ApplicationController
  # <tt>GET /weather</tt>
  #
  # Shows the form for the user to enter a location.
  def index
  end

  # <tt>GET /weather/forecast?location=[]</tt>
  #
  # Fetches the weather for the requested location and displays it.
  #
  # If for some reason the weather cannot be displayed, the user is returned to the form with an error message.
  #
  # When the location is not found, a 404 is returned and an error message is displayed.
  # When an error occurs while fetching the weather, a 500 is returned and an error message is displayed.
  def forecast
    requested_location = params[:location]
    api = WeatherApi.new(ENV["WEATHER_API_KEY"])
    @weather = api.fetch_weather(requested_location)
  rescue WeatherApi::LocationNotFound
    @error = "Location not found. Please try again."
    render :index, status: :not_found
  rescue WeatherApi::Error
    @error = "An error occurred while fetching the weather. Please try again later."
    render :index, status: :internal_server_error
  end
end
