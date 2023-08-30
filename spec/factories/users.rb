FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "email#{n}" }

    transient do
      movie_count { 1 }  
      season_count { 1 }  
    end

    trait :with_movie_purchases do
      after(:create) do |user, evaluator|
        create_list(:purchase, evaluator.movie_count, :with_movie, user: user)
      end
    end

    trait :with_season_purchases do
      after(:create) do |user, evaluator|
        create_list(:purchase, evaluator.season_count, :with_season, user: user)
      end
    end

  end
end
