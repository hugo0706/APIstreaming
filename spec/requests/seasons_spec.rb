require 'rails_helper'

RSpec.describe "Seasons", type: :request do
  describe "GET /index" do
    context 'when seasons exist' do
      let!(:season1) { FactoryBot.create(:season,:with_episodes,:with_purchase_options,purchase_options_count: 2) }
      let!(:season2) { FactoryBot.create(:season,:with_episodes,:with_purchase_options,episodes_count: 2) }
  
      it 'returns a list of seasons with status :ok' do
        allow(SeasonService).to receive(:get_seasons_desc_episodes_asc).and_return([season1,season2])

        get '/seasons'
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to be_an(Array)
        expect(JSON.parse(response.body).length).to eq(2)
        expect(JSON.parse(response.body)[0]).to include('id', 'title', 'plot','number', 'created_at', 'updated_at','episodes', 'purchase_options')
        expect(JSON.parse(response.body)[0]["purchase_options"].length).to eq(2)
        expect(JSON.parse(response.body)[0]["episodes"].length).to eq(1)
        expect(JSON.parse(response.body)[1]).to include('id', 'title', 'plot','number', 'created_at', 'updated_at','episodes', 'purchase_options')
        expect(JSON.parse(response.body)[1]["purchase_options"].length).to eq(1)
        expect(JSON.parse(response.body)[1]["episodes"].length).to eq(2)

      end
    end

    context 'when seasons dont exist' do
      it 'returns error "No seasons found" with status :not_found' do
        allow(SeasonService).to receive(:get_seasons_desc_episodes_asc).and_return([])

        get '/seasons'

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to include('error')
        expect(JSON.parse(response.body)["error"]).to eq("No seasons found")
      end
    end

    context 'when ActiveRecord::RecordNotFound is raised' do
      it 'returns error message with status :not_found' do
        allow(SeasonService).to receive(:get_seasons_desc_episodes_asc).and_raise(ActiveRecord::RecordNotFound)

        get '/seasons'

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to include('error')
      end
    end
    
    context 'when StandardError is raised' do
      it 'returns error message with status :internal_server_error' do
        allow(SeasonService).to receive(:get_seasons_desc_episodes_asc).and_raise(StandardError)

        get '/seasons'

        expect(response).to have_http_status(:internal_server_error)
      end
    end
  end


  describe "POST /create" do
    context 'when params are correct' do
  
      let(:params) {
        {
          "season": {
            "title": "season",
            "plot": "as",
            "number": 1,
            "purchase_options_attributes": [
                {
                "price": 2.99,
                "quality": "HD"
                },
                {
                "price": 3.99,
                "quality": "SD"
                }
            ],
            "episodes_attributes": [
                {
                "title": "EP1",
                "plot": "PLOT",
                "number": 1
                },
                {
                "title": "EP2",
                "plot": "PLOT",
                "number": 2
                }
            ]
          }
        }
        
      }
  
      it 'creates a new Season' do
        expect {
          post '/seasons', params: params
        }.to change(Season, :count).by(1)
      end
  
      it 'invalidates the cache' do
        allow(SeasonService).to receive(:get_seasons_desc_episodes_asc).and_call_original
        allow(Rails.cache).to receive(:fetch).and_call_original
        allow(Rails.cache).to receive(:delete).and_call_original
        allow(SeasonService).to receive(:invalidate_cache).and_call_original
        post '/seasons', params:  params
        expect(SeasonService).to have_received(:invalidate_cache)
        expect(SeasonService).to have_received(:get_seasons_desc_episodes_asc)
        expect(Rails.cache).to have_received(:delete).with('seasons_desc_episodes_asc')
        expect(Rails.cache).to have_received(:fetch).with('seasons_desc_episodes_asc')
      end
  
      it 'returns created status and the new season as JSON' do
        post '/seasons', params: params
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to include('id', 'title', 'plot','number', 'created_at', 'updated_at', 'episodes','purchase_options')
        expect(JSON.parse(response.body)["purchase_options"].length).to eq(2)
        expect(JSON.parse(response.body)["episodes"].length).to eq(2)
      end
    end

    context 'when params are incorrect' do
      let(:invalid_params) {
        {
          "Movie": {
            "title": "season",
            "plot": "plot",
            "number": 1,
            "purchase_options_attributes": [
                {
                "price": 2.99,
                "quality": "HD"
                }
            ],
            "episodes_attributes": [
                {
                "title": "EP1",
                "plot": "PLOT",
                "number": 1
                }
            ]
          }
        }
      }

      it 'does not create a new Season' do
        expect {
          post '/seasons', params: invalid_params
        }.to_not change(Season, :count)        
      end

      it 'returns unprocessable_entity status and error message' do
        post '/seasons', params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include('error')
      end
    end
  end
end
