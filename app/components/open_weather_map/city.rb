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
      (@temp_k - 272.15).round(2)
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
  end
end
