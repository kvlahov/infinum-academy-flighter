RSpec.describe OpenWeatherMap do
  it 'checks credentials' do
    expect(Rails.application.credentials.open_weather_map_api_key).not_to be_nil
  end
end
