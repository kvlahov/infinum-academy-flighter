FactoryBot.define do
  factory :flight do
    name { 'Flight 1' }
    flys_at { DateTime.new(2019, 7, 18, 16, 40) }
    lands_at { DateTime.new(2019, 7, 18, 18, 40) }
    base_price { 250 }
    company { create(:company) }
  end
end
