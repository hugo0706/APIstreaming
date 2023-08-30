FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "email#{n}" }
  end
end
