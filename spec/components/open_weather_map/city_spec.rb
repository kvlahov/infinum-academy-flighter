# frozen_string_literal: true

RSpec.describe OpenWeatherMap::City do
  let(:city) do
    described_class.new(
      id: 2_172_797,
      lat: -16.92,
      lon: 145.77,
      name: 'Cairns',
      temp_k: 273.15
    )
  end
  let(:other) { { id: nil, lat: nil, lon: nil, name: nil, temp_k: nil } }

  it 'checks attributes' do
    expect(city).to have_attributes(
      id: 2_172_797,
      lat: -16.92,
      lon: 145.77,
      name: 'Cairns'
    )
  end

  it 'checks temp calculation' do
    expect(city.temp).to eq(0)
  end

  it 'checks comparison between this and higher temp city' do
    other[:temp_k] = 350.15
    expect(city <=> described_class.new(**other)).to eq(-1)
  end

  it 'checks comparison between this and lower temp city' do
    other[:temp_k] = 270
    expect(city <=> described_class.new(**other)).to eq(1)
  end

  it 'checks comparison between this and same temp city,
      this name first alphabetically' do
    other[:name] = 'Kairo'
    other[:temp_k] = 273.15
    expect(city <=> described_class.new(**other)).to eq(-1)
  end

  it 'checks comparison between this and same temp city,
      this name second alphabetically' do
    other[:name] = 'Amsterdam'
    other[:temp_k] = 273.15
    expect(city <=> described_class.new(**other)).to eq(1)
  end

  it 'checks comparison between this and other city, same temp and name' do
    other[:name] = 'Cairns'
    other[:temp_k] = 273.15
    expect(city <=> described_class.new(**other)).to eq(0)
  end
end
