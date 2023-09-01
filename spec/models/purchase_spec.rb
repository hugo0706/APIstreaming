require 'rails_helper'

RSpec.describe Purchase, type: :model do
  describe 'validations' do
    let(:user) { FactoryBot.create(:user) }
    let(:movie) { FactoryBot.create(:movie,:with_purchase_options) }
    
    it "is valid with valid attributes" do
      purchase = Purchase.new(user: user, purchasable: movie, purchase_option: movie.purchase_options.first, expires_at: Time.now + 2.days)
      expect(purchase).to be_valid
    end

    it "is not valid without an expires_at" do
      purchase = Purchase.new(user: user, purchasable: movie, purchase_option: movie.purchase_options.first, expires_at: Time.now + 2.days)
      purchase.expires_at = nil
      expect(purchase).to_not be_valid
    end

    it "is not valid without a unique purchase_option_id" do
      purchase = Purchase.create!(user: user, purchasable: movie, purchase_option: movie.purchase_options.first, expires_at: Time.now + 2.days)
      purchase2 = Purchase.new(user: user, purchasable: movie, purchase_option: movie.purchase_options.first, expires_at: Time.now + 2.days)
      expect(purchase2).to_not be_valid
    end
  end
end