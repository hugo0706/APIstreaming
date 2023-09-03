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

  describe '.purchase_season' do
    let(:season) { FactoryBot.create(:season, :with_purchase_options) }
    let(:user) { FactoryBot.create(:user) }
    let(:params) { { user_id: user.id, purchasable_id: season.id, purchase_option_id: season.purchase_options.first.id, purchasable_type: season.class.to_s } }
    
    context 'when successful' do
      it 'creates a new purchase' do
        expect {
          SeasonService.purchase_season(params)
        }.to change { Purchase.count }.by(1)

        purchase = Purchase.last
        expect(purchase.purchasable).to eq(season)
        expect(purchase.purchase_option).to eq(season.purchase_options.first)
      end
    end

    context 'when season is not found' do
      it 'raises a RecordNotFound error' do
        params[:purchasable_id] = -1
        expect {
          SeasonService.purchase_season(params)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'when purchase option is not found' do
      it 'raises a RecordNotFound error' do
        params[:purchase_option_id] = -1
        expect {
          SeasonService.purchase_season(params)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

end