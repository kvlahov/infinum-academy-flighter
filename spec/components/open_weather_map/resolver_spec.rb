RSpec.describe OpenWeatherMap::Resolver do
  it 'checks if valid id' do
    expect(described_class.city_id('Gorkhā')).to eq(1_283_378)
  end

  it 'checks if returns nill for invalid name' do
    expect(described_class.city_id('blahaa')).to eq(nil)
  end
end
