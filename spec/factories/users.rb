FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@mail.com" }
    first_name { 'Netko' }
    password { 'usr123' }
    role { nil }
  end
end
