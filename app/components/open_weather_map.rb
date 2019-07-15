module OpenWeatherMap
  def self.city(name)
    city_id = OpenWeatherMap::Resolver.city_id(name)
    return nil if city_id.nil?

    response =
      JSON.parse(
        Faraday.get('https://api.openweathermap.org/data/2.5/weather',
                    { appid: Rails.application.credentials.open_weather_map_api_key.to_s,
                      id: city_id },
                    'Accept' => 'application/json').body
      )
    OpenWeatherMap::City.parse(response)
  end

  def self.cities(cityarr)
    ids = cityarr.map { |name| OpenWeatherMap::Resolver.city_id(name) }.compact.join(',')
    JSON.parse(
      Faraday.get('https://api.openweathermap.org/data/2.5/group',
                  { appid: Rails.application.credentials.open_weather_map_api_key.to_s,
                    id: ids },
                  'Accept' => 'application/json').body
    )['list'].map { |c| OpenWeatherMap::City.parse(c) }
  end
end
