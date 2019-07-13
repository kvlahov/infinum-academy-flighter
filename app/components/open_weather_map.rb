require 'faraday'
require 'json'

module OpenWeatherMap
  def self.city(name)
    city_id = OpenWeatherMap::Resolver.city_id(name)
    return nil if city_id.nil?

    response =
      Faraday.get('http://api.openweathermap.org/data/2.5/weather?id=' + city_id.to_s + '&appid=' +
      Rails.application.credentials[:open_weather_map_api_key])
    OpenWeatherMap::City.parse(JSON.parse(response.body))
  end

  def self.cities(cityarr)
    cityarr.map { |name| city(name) }.compact
  end
end
