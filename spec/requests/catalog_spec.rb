require 'rails_helper'

RSpec.describe "Catalog", type: :request do
  describe "GET /index" do
    let(:expected_keys) do 
      {
      'season' => ['id', 'type', 'title', 'plot', 'number', 'created_at', 'updated_at', 'episodes', 'purchase_options'],
      'movie'  => ['id', 'type', 'title', 'plot', 'created_at', 'updated_at', 'purchase_options']
      }
    end

    context 'when movies and seasons exist' do
      let!(:movie1) { FactoryBot.create(:movie,:with_purchase_options,purchase_options_count: 2) }
      let!(:movie2) { FactoryBot.create(:movie,:with_purchase_options) }
      let!(:season1) { FactoryBot.create(:season,:with_episodes,:with_purchase_options,purchase_options_count: 2) }
      let!(:season2) { FactoryBot.create(:season,:with_episodes,:with_purchase_options,episodes_count: 2) }
  
      it 'returns a list of movies and seasons with status :ok' do
        allow(CatalogService).to receive(:get_catalog_ordered).and_return([season2,season1,movie2,movie1])
        
        get '/catalog'

        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(json_response).to be_an(Array)
        expect(json_response.length).to eq(4)
        json_response.each do |item|
          
          keys = item.keys
          expect(keys).to contain_exactly(*expected_keys[item['type']])
          expect(item["purchase_options"].length).to be > 0
          if item['type'] == 'season'
            expect(item["episodes"]).to be_an(Array)
            expect(item["episodes"].length).to be > 0
          else
            expect(item).not_to include("episodes")
          end
        end
      end
    end

    context 'when movies and seasons dont exist' do
      it 'returns error "No catalog found" with status :ok' do
        allow(CatalogService).to receive(:get_catalog_ordered).and_return([])
        
        get '/catalog'

        expect(response).to have_http_status(:ok)
        expect(response.body).to eq("[]")
        
      end
    end

  end
end
