RSpec.describe CatalogService do
  let(:time_now) { Time.now }
  let(:movie1){ FactoryBot.create(:movie, created_at: time_now ) }
  let(:season1){ FactoryBot.create(:season, created_at: time_now + 2.minutes) }
  let(:movie2){ FactoryBot.create(:movie, created_at: time_now + 3.minutes) }
  let(:season2){ FactoryBot.create(:season, created_at: time_now + 4.minutes) }

  describe '.get_catalog' do
    it 'returns a list of available movies and seasons' do

      allow(MovieService).to receive(:get_movies_by_descending_creation).and_return([movie1, movie2])
      allow(SeasonService).to receive(:get_seasons_desc_episodes_asc).and_return([season1, season2])

      result = CatalogService.get_catalog
      expect(result).to eq([movie1, movie2, season1, season2])
    end
  end

  describe '.get_catalog_ordered' do
    it 'returns a combined and ordered list of movies and seasons by creation date' do
    
      allow(MovieService).to receive(:get_movies_by_descending_creation).and_return([movie1, movie2])
      allow(SeasonService).to receive(:get_seasons_desc_episodes_asc).and_return([season1, season2])

      result = CatalogService.get_catalog_ordered

      expect(result).to eq([season2,movie2,season1,movie1])
    end
  end
end
