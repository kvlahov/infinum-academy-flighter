FactoryBot.define do
  factory :flight do
    name { 'Flight 1' }
    flys_at { 2.days.from_now }
    lands_at { 2.days.from_now + 2.hours }
    base_price { 250 }
    no_of_seats { 200 }
    company { create(:company) }
  end
end
