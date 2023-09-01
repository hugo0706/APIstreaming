require 'rails_helper'

RSpec.describe Movie, type: :model do
  describe 'validations' do
    it 'is valid with correct params' do
      movie = Movie.new(title: 'Title', plot: 'plot')
      expect(movie).to be_valid
    end

    it 'is not valid without a title' do
      movie = Movie.new(title: nil, plot: 'plot')
      expect(movie).to_not be_valid
    end

    it 'is not valid without a plot' do
      movie = Movie.new(title: "title", plot: nil)
      expect(movie).to_not be_valid
    end
    
  end

end
