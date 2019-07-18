RSpec.describe Flight do
  subject(:flight) { FactoryBot.create(:flight) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive.scoped_to(:company_id) }
  it { is_expected.to validate_presence_of(:flys_at) }
  it { is_expected.to validate_presence_of(:lands_at) }

  it { is_expected.to validate_presence_of(:base_price) }
  it { is_expected.to validate_numericality_of(:base_price).is_greater_than(0) }
  it { is_expected.to validate_presence_of(:no_of_seats) }
  it { is_expected.to validate_numericality_of(:no_of_seats).is_greater_than(0) }

  context 'when flys_at greater than lands_at' do
    subject(:flight) { FactoryBot.build(:flight, flys_at: DateTime.current, lands_at: 1.day.ago) }

    it 'checks if is invalid' do
      flight.valid?
      expect(flight.errors['flys_at']).to include('must be before landing time')
    end
  end
end
