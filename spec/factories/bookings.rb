FactoryBot.define do
  factory :booking do
    no_of_seats { 5 }
    seat_price { 150 }

    user { create(:user) }
    flight { create(:flight) }
  end
end
