require 'rails_helper'

RSpec.describe "Purchases", type: :request do
  describe "POST /purchase" do
    let(:movie) { FactoryBot.create(:movie,:with_purchase_options) }
    let(:user) { FactoryBot.create(:user) }      
    let(:season) { FactoryBot.create(:season,:with_episodes,:with_purchase_options) }

    let(:expected_keys) do 
      ['id','user_id','email','title','purchase_option','purchasable_type','purchasable_id','expires_at','created_at','updated_at']
    end
    
    context 'when purchase is a movie' do

      it 'creates a purchase' do
        params_movie ={
            "purchase": {
              "purchasable_type": "Movie",
              "purchasable_id": movie.id,
              "user_id": user.id,
              "purchase_option_id": movie.purchase_options.first.id
            }
          }
        expect{
          post '/purchase', params: params_movie
        }.to change(Purchase, :count).by(1)
      end

      it 'returns a purchased movie and status :created' do
        params_movie ={
            "purchase": {
              "purchasable_type": "Movie",
              "purchasable_id": movie.id,
              "user_id": user.id,
              "purchase_option_id": movie.purchase_options.first.id
            }
          }

        post '/purchase', params: params_movie
        expect(response).to have_http_status(:created)
        response_json = JSON.parse(response.body)
        keys = response_json.keys
        expect(keys).to contain_exactly(*expected_keys)
        expect(response_json["purchasable_type"]).to eq("Movie")
      end
    end

    context 'when purchase is a season' do

      it 'creates a purchase' do
        params_season ={
            "purchase": {
              "purchasable_type": "Season",
              "purchasable_id": season.id,
              "user_id": user.id,
              "purchase_option_id": season.purchase_options.first.id
            }
          }
        expect{
          post '/purchase', params: params_season
        }.to change(Purchase, :count).by(1)
      end

      it 'returns a purchased season and status :created' do
        params_season ={
          "purchase": {
            "purchasable_type": "Season",
            "purchasable_id": season.id,
            "user_id": user.id,
            "purchase_option_id": season.purchase_options.first.id
          }
        }

        post '/purchase', params: params_season
        expect(response).to have_http_status(:created)
        response_json = JSON.parse(response.body)
        keys = response_json.keys
        expect(keys).to contain_exactly(*expected_keys)
        expect(response_json["purchasable_type"]).to eq("Season")
      end
    end
  
    context 'when params are incorrect' do
      it 'returns error status 422' do
        post '/purchase', params: {}

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('error')
      end
    end
  
    context 'when trying to purchase a movie twice' do
      it 'returns error Purchase option has already been taken status 422' do
        params_movie ={
            "purchase": {
              "purchasable_type": "Movie",
              "purchasable_id": movie.id,
              "user_id": user.id,
              "purchase_option_id": movie.purchase_options.first.id
            }
          }

        post '/purchase', params: params_movie
        post '/purchase', params: params_movie

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('Purchase option has already been taken')
      end
    end
  
    context 'when trying to purchase a movie twice two days later' do
      it 'returns a purchased movie and status :created' do
        params_movie ={
          "purchase": {
            "purchasable_type": "Movie",
            "purchasable_id": movie.id,
            "user_id": user.id,
            "purchase_option_id": movie.purchase_options.first.id
          }
        }
        post '/purchase', params: params_movie
        expect(response).to have_http_status(:created) 
        response_json = JSON.parse(response.body)
        keys = response_json.keys
        expect(keys).to contain_exactly(*expected_keys)
        expect(response_json["purchasable_type"]).to eq("Movie")

        Timecop.travel(2.days.from_now) do
          post '/purchase', params: params_movie
          expect(response).to have_http_status(:created)
          response_json = JSON.parse(response.body)
          keys = response_json.keys
          expect(keys).to contain_exactly(*expected_keys)
          expect(response_json["purchasable_type"]).to eq("Movie")
        end
      end
    end
  end
  
end
