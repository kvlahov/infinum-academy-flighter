require 'json'

module OpenWeatherMap
  module Resolver
    def self.city_id(name)
      data = JSON.parse(File.read(File.expand_path('city_ids.json', __dir__)))
      data.select { |city| city['name'] == name }.map { |city| city['id'] }.first
    end
  end
end
