require 'rails_helper'

RSpec.describe "Movies", type: :request do
  describe "GET /index" do
    context 'when movies exist' do
      let!(:movie1) { FactoryBot.create(:movie, title: "Movie1", plot: "Plot1") }
      let!(:movie2) { FactoryBot.create(:movie, title: "Movie2", plot: "Plot2") }

      it 'returns a list of movies with status :ok' do
        allow(MovieService).to receive(:get_movies_by_descending_creation).and_return([movie1,movie2])

        get '/movies'

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to be_an(Array)
        expect(JSON.parse(response.body).length).to eq(2)
        expect(JSON.parse(response.body)[0]).to include('id', 'title', 'plot', 'created_at', 'updated_at', 'purchase_options')
        expect(JSON.parse(response.body)[1]).to include('id', 'title', 'plot', 'created_at', 'updated_at', 'purchase_options')
      end
    end

    context 'when movies dont exist' do
      it 'returns error "No movies found" with status :not_found' do
        allow(MovieService).to receive(:get_movies_by_descending_creation).and_return([])

        get '/movies'

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to include('error')
        expect(JSON.parse(response.body)["error"]).to eq("No movies found")
      end
    end

    context 'when ActiveRecord::RecordNotFound is raised' do
      it 'returns error message with status :not_found' do
        allow(MovieService).to receive(:get_movies_by_descending_creation).and_raise(ActiveRecord::RecordNotFound)

        get '/movies'

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to include('error')
      end
    end

    context 'when StandardError is raised' do
      it 'returns error message with status :internal_server_error' do
        allow(MovieService).to receive(:get_movies_by_descending_creation).and_raise(StandardError)

        get '/movies'

        expect(response).to have_http_status(:internal_server_error)
      end
    end
  end
end
