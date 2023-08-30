FactoryBot.define do
  factory :purchase do
    user
    purchasable { nil }  
    purchase_option { nil }
    expires_at { Time.now + 2.days }


    trait :with_movie do
      after(:build) do |purchase|
        movie = create(:movie,:with_purchase_options)
        purchase.purchasable = movie
        purchase.purchase_option = movie.purchase_options.first
      end
    end

    trait :with_season do
      after(:build) do |purchase|
        season = create(:season,:with_episodes,:with_purchase_options)
        purchase.purchasable = season
        purchase.purchase_option = season.purchase_options.first
      end
    end
  end
end
