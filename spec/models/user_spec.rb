RSpec.describe User do
  subject { FactoryBot.create(:user) }

  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_length_of(:first_name).is_at_least(2) }

  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  it { is_expected.to allow_value('email@addresse.foo').for(:email) }
  it { is_expected.not_to allow_value('sdmail.com').for(:email) }
end
