FactoryBot.define do
  factory :season do
    sequence(:title) { |n| "Season #{n}" }
    sequence(:plot)  { |n| "Season #{n}" }
    sequence(:number) { |n| n }

    transient do
      episodes_count { 1 }  
      purchase_options_count { 1 }  
    end
    
    trait :with_episodes do
      after(:create) do |season, evaluator|
        create_list(:episode, evaluator.episodes_count, season: season) 
      end
    end
    trait :with_purchase_options do
      after(:create) do |season, evaluator|
        create_list(:purchase_option, evaluator.purchase_options_count, optionable: season)
      end
    end
  end
end
