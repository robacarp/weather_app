require "test_helper"

class WeatherApiTest < ActiveSupport::TestCase
  setup do
    @api = WeatherApi.new("api_key")
  end

  def dummy_data
    {
      "location" => { "name" => "London", "lat" => 51.51, "lon" => -0.13 },
      "current" => { "feelslike_f" => 80, "condition" => { "text" => "Sunny", "icon" => "//cdn.weatherapi.com/weather/64x64/day/116.png" } },
      "forecast" => {
        "forecastday" => [
          { "date" => "2024-02-12", "day" => { "maxtemp_f" => 80, "mintemp_f" => 60, "daily_chance_of_rain" => 20, "condition" => { "text" => "Sunny", "icon" => "//cdn.weatherapi.com/weather/64x64/day/116.png" } } },
          { "date" => "2024-02-13", "day" => { "maxtemp_f" => 82, "mintemp_f" => 62, "daily_chance_of_rain" => 30, "condition" => { "text" => "Sunny", "icon" => "//cdn.weatherapi.com/weather/64x64/day/116.png" } } },
          { "date" => "2024-02-14", "day" => { "maxtemp_f" => 84, "mintemp_f" => 64, "daily_chance_of_rain" => 40, "condition" => { "text" => "Sunny", "icon" => "//cdn.weatherapi.com/weather/64x64/day/116.png" } } }
        ]
      }
    }
  end

  def not_found_data
    { "error" => { "message" => "No matching location found" } }
  end

  test "fetches the weather for a location" do
    @api.stub :request, dummy_data do
      response = @api.fetch_weather("London")
      assert_equal "London", response.location.name
    end
  end

  test "response object provides access to current conditions" do
    @api.stub :request, dummy_data do
      response = @api.fetch_weather("London")
      assert_equal 80, response.conditions.temperature
    end
  end

  test "response object provides access to the forecast" do
    @api.stub :request, dummy_data do
      response = @api.fetch_weather("London")
      assert_equal 3, response.daily_forecasts.size
      assert_equal 80, response.daily_forecasts.first.high
    end
  end

  test "it caches successful requests" do
    # Activate a cache store just for this test
    Rails.stub :cache, ActiveSupport::Cache::MemoryStore.new do
      @api.stub :request, dummy_data do
        # First request is not cached
        response = @api.fetch_weather("Denver")
        assert_not response.cached?

        # Second request is cached
        response = @api.fetch_weather("Denver")
        assert response.cached?
      end
    end
  end

  test "it logs a CACHEMISS when a request is not cached" do
    mock_logger = Minitest::Mock.new
    mock_logger.expect(:info, nil, ["WeatherAPI CACHEMISS for 'Chicago'"])

    Rails.stub :logger, mock_logger do
      @api.stub :request, dummy_data do
        output = capture_subprocess_io do
          @api.fetch_weather("Chicago")
        end
      end
    end
  end

  test "it raises an error when the location is not found" do
    @api.stub :request, not_found_data do
      assert_raises WeatherApi::LocationNotFound do
        @api.fetch_weather("Atlantis")
      end
    end
  end

  test "it raises an error when the API call fails" do
    @api.stub :request, ->(_url, _params) { raise WeatherApi::Error } do
      assert_raises WeatherApi::Error do
        @api.fetch_weather("Denver")
      end
    end
  end
end
