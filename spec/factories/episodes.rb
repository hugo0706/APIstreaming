FactoryBot.define do
  factory :episode do
    sequence(:title) { |n| "EP #{n}" }
    sequence(:plot)  { |n| "EP #{n}" }
    sequence(:number) { |n| n }
    association :season
  end
end
