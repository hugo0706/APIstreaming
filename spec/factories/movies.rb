FactoryBot.define do
  factory :movie do
    sequence(:title) { |n| "Movie #{n}" }
    sequence(:plot)  { |n| "Movie #{n}" }

    transient do
      purchase_options_count { 1 }  
    end

    trait :with_purchase_options do
      after(:create) do |movie, evaluator|
        create_list(:purchase_option, evaluator.purchase_options_count, optionable: movie)
      end
    end
  end
end
