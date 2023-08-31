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
end
