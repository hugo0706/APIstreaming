require 'rails_helper'

RSpec.describe PurchaseOption, type: :model do
  let(:movie) { Movie.create!(title: 'title', plot: 'plot') }
  let(:season) { Season.create!(title: 'title', plot: 'plot', number: 1) }
  describe 'validations' do
    it 'is valid with correct params' do
      purchase_option = PurchaseOption.new(price: 2.99, quality: 'HD', optionable: movie)
      expect(purchase_option).to be_valid
    end

    it 'is valid with price 0' do
      purchase_option = PurchaseOption.new(price: 0, quality: 'HD', optionable: movie)

      expect(purchase_option).to be_valid
    end

    it 'is not valid without a price' do
      purchase_option = PurchaseOption.new(price: nil, quality: 'HD', optionable: movie)
      expect(purchase_option).to_not be_valid
    end

    it 'is not valid with a negative price' do
      purchase_option = PurchaseOption.new(price: -1, quality: 'HD', optionable: movie)
      expect(purchase_option).to_not be_valid
    end

    it 'is not valid without a quality' do
      purchase_option = PurchaseOption.new(price: 2.99, quality: nil, optionable: movie)
      expect(purchase_option).to_not be_valid
    end

    it 'is not valid with a quality not in [HD, SD]' do
      purchase_option = PurchaseOption.new(price: 2.99, quality: 'HHD', optionable: movie)
      expect(purchase_option).to_not be_valid
    end
  end
end