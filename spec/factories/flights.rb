FactoryBot.define do
  factory :flight do
    sequence(:name) { |n| "Flight #{n}" }
    flys_at { 2.days.from_now }
    lands_at { flys_at + 2.hours }
    base_price { 250 }
    no_of_seats { 200 }
    company { create(:company) }
  end
end
