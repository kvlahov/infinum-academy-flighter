FactoryBot.define do
  factory :company do
    sequence(:name) { |n| "Company Name#{n}" }
  end
end
