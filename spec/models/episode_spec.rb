require 'rails_helper'

RSpec.describe Episode, type: :model do
  describe 'validations' do
    let(:season) { Season.create!(title: 'title', plot: 'plot', number: 1) }
    
    it 'is valid with correct params' do
      episode = Episode.new(title: 'title', plot: 'plot', number: 1, season: season)
      expect(episode).to be_valid
    end

    it 'is not valid without a title' do
      episode = Episode.new(title: nil, plot: 'plot', number: 1, season: season)
      expect(episode).to_not be_valid
    end

    it 'is not valid without a plot' do
      episode = Episode.new(title: 'title', plot: nil, number: 1, season: season)
      expect(episode).to_not be_valid
    end

    it 'is not valid without a number' do
      episode = Episode.new(title: 'title', plot: 'plot', number: nil, season: season)
      expect(episode).to_not be_valid
    end

    it 'is not valid with a negative number, zero or float' do
      episode = Episode.new(title: 'title', plot: 'plot', number: -1, season: season)
      expect(episode).to_not be_valid

      episode.number = 0
      expect(episode).to_not be_valid

      episode.number = 1.5
      expect(episode).to_not be_valid
    end

    it 'is not valid with a repeated number within the same season' do
      Episode.create!(title: 'title', plot: 'plot', number: 1, season: season)
      episode = Episode.new(title: 'title', plot: 'plot', number: 1, season: season)
      expect(episode).to_not be_valid
    end
  end

end
