FactoryBot.define do
  factory :booking do
    no_of_seats { 5 }
    seat_price { 10 }
    user { create(:user) }
    flight { create(:flight) }
  end
end
