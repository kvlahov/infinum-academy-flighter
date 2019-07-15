FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@mail.com" }
    first_name { 'Netko' }
  end
end
