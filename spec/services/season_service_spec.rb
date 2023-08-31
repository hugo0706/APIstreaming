RSpec.describe SeasonService do
  let(:time_now) { Time.now }
  let(:season1){ FactoryBot.create(:season, created_at: time_now ) }
  let(:season2){ FactoryBot.create(:season, created_at: time_now + 3.minutes) }

  describe '.get_seasons_desc_episodes_asc' do
    context 'when seasons exist' do
      it 'returns a list of available seasons' do
        result = SeasonService.get_seasons_desc_episodes_asc
        expect(result).to eq([season2,season1])
      end

      it 'fetches the list of season from the cache' do
        allow(Rails.cache).to receive(:fetch).and_call_original
        result = SeasonService.get_seasons_desc_episodes_asc
        expect(Rails.cache).to have_received(:fetch).with('seasons_desc_episodes_asc')
      end
    end
    context 'when seasons dont exist' do
      it 'returns an empty list' do
        result = SeasonService.get_seasons_desc_episodes_asc
        expect(result).to eq([])
      end
    end
  end

  describe '.invalidate_cache' do
    it 'invalidates the cache' do
      allow(Rails.cache).to receive(:delete).and_call_original
      allow(SeasonService).to receive(:get_seasons_desc_episodes_asc).and_return([])
      SeasonService.invalidate_cache
      expect(Rails.cache).to have_received(:delete).with('seasons_desc_episodes_asc')
    end
  end

  

end