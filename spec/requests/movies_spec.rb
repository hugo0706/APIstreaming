require 'rails_helper'

RSpec.describe "Movies", type: :request do
  describe "GET /index" do

    let(:expected_keys) do 
      ['id', 'type', 'title', 'plot', 'created_at', 'updated_at', 'purchase_options']
    end

    context 'when movies exist' do
      let!(:movie1) { FactoryBot.create(:movie,:with_purchase_options,purchase_options_count: 2) }
      let!(:movie2) { FactoryBot.create(:movie,:with_purchase_options) }
  
      it 'returns a list of movies with status :ok' do
        allow(MovieService).to receive(:get_movies_by_descending_creation).and_return([movie1,movie2])

        get '/movies'
        
        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(json_response).to be_an(Array)
        expect(json_response.length).to eq(2)
        json_response.each do |item|
          keys = item.keys
          expect(keys).to contain_exactly(*expected_keys)
        end
        expect(json_response[0]["purchase_options"].length).to eq(2)
        expect(json_response[1]["purchase_options"].length).to eq(1)

      end
    end

    context 'when movies dont exist' do
      it 'returns empty array with status :ok' do
        allow(MovieService).to receive(:get_movies_by_descending_creation).and_return([])

        get '/movies'

        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(json_response).to eq([])
      end
    end

    context 'when ActiveRecord::RecordNotFound is raised' do
      it 'returns error message with status :not_found' do
        allow(MovieService).to receive(:get_movies_by_descending_creation).and_raise(ActiveRecord::RecordNotFound)

        get '/movies'

        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:not_found)
        expect(json_response).to include('error')
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


  describe "POST /create" do

    let(:expected_keys) do 
      ['id', 'type', 'title', 'plot', 'created_at', 'updated_at', 'purchase_options']
    end

    context 'when params are correct' do
  
      let(:params) {
        {
          "movie": {
            "title": "movie",
            "plot": "plot",
            "purchase_options_attributes": [
                {
                "price": 2.99,
                "quality": "HD"
                }
            ]
          }
        }
      }
  
      it 'creates a new Movie' do
        expect {
          post '/movies', params: params
        }.to change(Movie, :count).by(1)
      end
  
      it 'invalidates the cache' do
        allow(Rails.cache).to receive(:delete).and_call_original
        allow(MovieService).to receive(:invalidate_cache).and_call_original
        post '/movies', params:  params
        expect(MovieService).to have_received(:invalidate_cache)
        expect(Rails.cache).to have_received(:delete).with('movies_by_descending_creation')
      end
  
      it 'returns created status and the new movie as JSON' do
        
        post '/movies', params: params
        
        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:created)
        keys = json_response.map { |key, _value| key }
        expect(keys).to contain_exactly(*expected_keys)
        expect(json_response["purchase_options"].length).to eq(1)
      end
    end

    context 'when params lack movie key' do
      let(:invalid_params) {
        {
          "title": "movie",
          "plot": "as",
          "purchase_options_attributes": [
              {
              "price": 2.99,
              "quality": "HD"
              }
          ]
        }
      }

      it 'does not create a new Movie' do
        expect {
          post '/movies', params: invalid_params
        }.to_not change(Movie, :count)        
      end

      it 'returns unprocessable_entity status and error message' do
        
        post '/movies', params: invalid_params
        
        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response).to include('error')
      end
    end
  
    context 'when other param is incorrect' do
  
      let(:params1) {
        {
          "movie": {
            "title": "movie",
            "plot": "plot",
            "purchase_options_attributes": [
                {
                "price": "a",
                "quality": "HD"
                }
            ]
          }
        }
      }
      let(:params2) {
        {
          "movie": {
            "title": "movie",
            "plot": "plot",
            "purchase_options_attributes": [
                {
                "price": 2.99,
                "quality": "HHHHD"
                }
            ]
          }
        }
      }
  
      it 'doesnt create a new Movie' do
        expect {
          post '/movies', params: params1
        }.to change(Movie, :count).by(0)
        expect {
          post '/movies', params: params2
        }.to change(Movie, :count).by(0)
      end

      it 'returns json with error and status :unprocessable_entity' do
        post '/movies', params: params1

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('error')
        post '/movies', params: params2

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('error')
      end
    end
  end

  describe "DELETE /destroy" do
    let(:movie) { FactoryBot.create(:movie,:with_purchase_options,purchase_options_count: 3) }
    let(:purchase) { FactoryBot.create(:purchase, purchasable: movie, purchase_option: movie.purchase_options.first)}
    context 'when movie exists' do
      
      it 'deletes the movie' do
        delete '/movies/'+movie.id.to_s 
        expect(response).to have_http_status(:no_content)
        expect(Movie.count).to eq(0)
      end

      it 'deletes the movie purchases' do
        purchase
        expect(Purchase.count).to eq(1)
        delete '/movies/'+movie.id.to_s 
        expect(response).to have_http_status(:no_content)
        expect(Purchase.count).to eq(0)
      end

      it 'deletes the movie purchase_options' do
        movie
        expect(PurchaseOption.count).to eq(3)
        delete '/movies/'+movie.id.to_s 
        expect(response).to have_http_status(:no_content)
        expect(PurchaseOption.count).to eq(0)
      end
    end
  end
end
