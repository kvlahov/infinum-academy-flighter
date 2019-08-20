RSpec.describe Booking do
  subject(:booking) { FactoryBot.create(:booking) }

  it { is_expected.to validate_presence_of(:no_of_seats) }
  it { is_expected.to validate_presence_of(:seat_price) }
  it { is_expected.to validate_numericality_of(:no_of_seats).is_greater_than(0) }
  it { is_expected.to validate_numericality_of(:seat_price).is_greater_than(0) }

  context 'when flys_at is in the past' do
    let(:booking) do
      FactoryBot.build(
        :booking,
        flight: FactoryBot.build(:flight, flys_at: 1.day.ago)
      )
    end

    it 'checks if flight in the past raises error' do
      booking.valid?
      expect(booking.errors['flight']).to include('flights can\'t be in the past')
    end
  end

  context 'when flight is overbooked' do
    let!(:flight) { FactoryBot.create(:flight, no_of_seats: 20) }
    let(:booking) { FactoryBot.build(:booking, flight: flight, no_of_seats: 50) }

    it 'returns false when checking validity' do
      expect(booking.valid?).to eq(false)
    end

    it 'raises error' do
      booking.valid?
      expect(booking.errors['no_of_seats']).to include('not enough seats available')
    end
  end
end
