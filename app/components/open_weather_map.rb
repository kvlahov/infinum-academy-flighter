require 'faraday'
require 'json'

module OpenWeatherMap
  def self.city(name)
    city_id = OpenWeatherMap::Resolver.city_id(name)
    return nil if city_id.nil?

    response = owm_api_call('weather', city_id.to_s)
    OpenWeatherMap::City.parse(response)
  end

  def self.cities(cityarr)
    ids = cityarr.map { |name| OpenWeatherMap::Resolver.city_id(name) }.join(',')
    owm_api_call('group', ids)['list'].map { |c| OpenWeatherMap::City.parse(c) }
  end

  private_class_method def self.owm_api_call(type, ids)
    JSON.parse(
      Faraday.get("https://api.openweathermap.org/data/2.5/#{type}?id=" + ids + '&appid=' +
      Rails.application.credentials.open_weather_map_api_key.to_s).body
    )
  end
end
