RSpec.describe MovieService do
  let(:time_now) { Time.now }
  let(:movie1){ FactoryBot.create(:movie, created_at: time_now ) }
  let(:movie2){ FactoryBot.create(:movie, created_at: time_now + 3.minutes) }

  describe '.get_movies_by_descending_creation' do
    context 'when movies exist' do
      it 'returns a list of available movies' do
        result = MovieService.get_movies_by_descending_creation
        expect(result).to eq([movie2,movie1])
      end

      it 'fetches the list of movies from the cache' do
        allow(Rails.cache).to receive(:fetch).and_call_original
        result = MovieService.get_movies_by_descending_creation
        expect(Rails.cache).to have_received(:fetch).with('movies_by_descending_creation')
      end
    end
    context 'when movies dont exist' do
      it 'returns an empty list' do
        result = MovieService.get_movies_by_descending_creation
        expect(result).to eq([])
      end
    end
  end

  describe '.purchase_movie' do
    let(:movie) { FactoryBot.create(:movie, :with_purchase_options) }
    let(:user) { FactoryBot.create(:user) }
    let(:params) { { user_id: user.id, purchasable_id: movie.id, purchase_option_id: movie.purchase_options.first.id } }
    
    context 'when successful' do
      it 'creates a new purchase' do
        expect {
          MovieService.purchase_movie(params)
        }.to change { Purchase.count }.by(1)

        purchase = Purchase.last
        expect(purchase.purchasable).to eq(movie)
        expect(purchase.purchase_option).to eq(movie.purchase_options.first)
      end
    end

    context 'when movie is not found' do
      it 'raises a RecordNotFound error' do
        params[:purchasable_id] = -1
        expect {
          MovieService.purchase_movie(params)
        }.to raise_error(ActiveRecord::RecordNotFound, "Movie not found")
      end
    end

    context 'when purchase option is not found' do
      it 'raises a RecordNotFound error' do
        params[:purchase_option_id] = -1
        expect {
          MovieService.purchase_movie(params)
        }.to raise_error(ActiveRecord::RecordNotFound, "Purchase option not found")
      end
    end
  end
end
