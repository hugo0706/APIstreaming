require 'rails_helper'

RSpec.describe Season, type: :model do
  describe 'validations' do
    it 'is valid with correct params' do
      season = Season.new(title: 'title', plot: 'plot', number: 1)
      expect(season).to be_valid
    end

    it 'is not valid without a title' do
      season = Season.new(title: nil, plot: 'plot', number: 1)
      expect(season).to_not be_valid
    end

    it 'is not valid without a plot' do
      season = Season.new(title: 'title', plot: nil, number: 1)
      expect(season).to_not be_valid
    end

    it 'is not valid without a number' do
      season = Season.new(title: 'title', plot: 'plot', number: nil)
      expect(season).to_not be_valid
    end

    it 'is not valid with a negative number, zero or float' do
      season = Season.new(title: 'title', plot: 'plot', number: -1)
      expect(season).to_not be_valid

      season.number = 0
      expect(season).to_not be_valid

      season.number = 1.5
      expect(season).to_not be_valid
    end
  end

end
