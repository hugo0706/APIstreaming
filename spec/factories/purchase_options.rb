FactoryBot.define do
  factory :purchase_option do
    optionable { nil }
    price { "9.99" }
    quality { "MyString" }
  end
end
