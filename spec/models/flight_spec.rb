RSpec.describe Flight do
  let(:flight) { FactoryBot.create(:flight) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive.scoped_to(:company_id) }
  it { is_expected.to validate_presence_of(:flys_at) }
  it { is_expected.to validate_presence_of(:lands_at) }

  it { is_expected.to validate_presence_of(:base_price) }
  it { is_expected.to validate_numericality_of(:base_price).is_greater_than(0) }
  it { is_expected.to validate_presence_of(:no_of_seats) }
  it { is_expected.to validate_numericality_of(:no_of_seats).is_greater_than(0) }

  context 'when flys_at greater than lands_at' do
    let(:flight) { FactoryBot.build(:flight, flys_at: DateTime.current, lands_at: 1.day.ago) }

    it 'checks if is invalid' do
      flight.valid?
      expect(flight.errors['flys_at']).to include('must be before landing time')
    end
  end

  context 'when flight is overlapping with another' do
    let(:company) { FactoryBot.create(:company) }
    let(:flight) do
      FactoryBot.build(
        :flight, flys_at: 1.day.from_now, lands_at: 2.days.from_now + 5.hours, company: company
      )
    end

    before do
      FactoryBot.create(
        :flight, flys_at: 1.day.from_now, lands_at: 3.days.from_now, company: company
      )
    end

    it 'throws error' do
      flight.valid?

      expect(flight.valid?).to eq(false)
      expect(flight.errors['flys_at'])
        .to include('flight schedule is overlapping with another flight')
    end
  end

  context 'when calculating flight price' do
    let(:base_price) { 100 }
    let!(:flight) { FactoryBot.create(:flight, flys_at: 2.days.from_now, base_price: base_price) }

    it 'doubles the price on flight day' do
      expect(flight.current_price(2.days.from_now)).to eq(base_price * 2)
    end
  end
end
