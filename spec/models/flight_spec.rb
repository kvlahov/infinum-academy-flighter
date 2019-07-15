let(:flight) { FactoryBot.create(flight) }

RSpec.describe Flight do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive.scoped_to(:company_id) }
  it { is_expected.to validate_presence_of(:flys_at) }
  it { is_expected.to validate_presence_of(:lands_at) }
end
