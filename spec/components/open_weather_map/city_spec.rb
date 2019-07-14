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
    other = described_class.new(
      id: 2_172_797,
      lat: -16.92,
      lon: 145.77,
      name: 'Zagreb',
      temp_k: 350.15
    )

    expect(city <=> other).to eq(-1)
  end

  it 'checks comparison between this and lower temp city' do
    other = described_class.new(
      id: 2_172_797,
      lat: -16.92,
      lon: 145.77,
      name: 'Zagreb',
      temp_k: 270.15
    )
    expect(city <=> other).to eq(1)
  end

  it 'checks comparison between this and same temp city,
      this name first alphabetically' do
    other = described_class.new(
      id: 2_172_797,
      lat: -16.92,
      lon: 145.77,
      name: 'Kairo',
      temp_k: 273.15
    )
    expect(city <=> other).to eq(-1)
  end

  it 'checks comparison between this and same temp city,
      this name second alphabetically' do
    other = described_class.new(
      id: 2_172_797,
      lat: -16.92,
      lon: 145.77,
      name: 'Amsterdam',
      temp_k: 273.15
    )
    expect(city <=> other).to eq(1)
  end

  it 'checks comparison between this and other city, same temp and name' do
    other = described_class.new(
      id: 2_172_797,
      lat: -16.92,
      lon: 145.77,
      name: 'Cairns',
      temp_k: 273.15
    )
    expect(city <=> other).to eq(0)
  end
end
