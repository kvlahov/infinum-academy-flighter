module OpenWeatherMap
  class City
    include Comparable
    attr_reader :id, :lat, :lon, :name
    def initialize(id:, name:, lat:, lon:, temp_k:)
      @id = id
      @name = name
      @lat = lat
      @lon = lon
      @temp_k = temp_k
    end

    def temp
      (@temp_k - 273.15).round(2)
    end

    def <=>(other)
      return temp <=> other.temp unless (temp <=> other.temp).zero?

      name <=> other.name
    end

    def self.parse(input)
      new(
        id: input['id'],
        name: input['name'],
        lat: input['coord']['lat'],
        lon: input['coord']['lon'],
        temp_k: input['main']['temp']
      )
    end

    def nearby(count = 5)
      response =
        Faraday.get('https://api.openweathermap.org/data/2.5/find',
                    { appid: Rails.application.credentials.open_weather_map_api_key,
                      lat: lat,
                      lon: lon,
                      cnt: count },
                    'Accept' => 'application/json')
      JSON.parse(response.body)['list']
          .map { |c| OpenWeatherMap::City.parse(c) }
    end

    def coldest_nearby(*count)
      nearby(*count).min
    end
  end
end
