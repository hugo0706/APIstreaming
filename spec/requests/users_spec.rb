require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "GET /profile/library" do
    let(:expected_keys) do 
        ['purchasable','purchase_option','expires_at']
    end
    let(:user) { FactoryBot.create(:user,:with_movie_purchases,:with_season_purchases, movie_count:2, season_count:1) }
    context 'when user has purchases' do
      it 'returns a list of seasons/movies with status :ok' do
        get '/profile/library?user_id='+user.id.to_s
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        json_response.each do |item|
          keys = item.keys
          expect(keys).to contain_exactly(*expected_keys)
        end
      end
    end

    context 'when user has no purchases' do
      it 'returns empty array with status :ok' do
        user = FactoryBot.create(:user)
        get '/profile/library?user_id='+user.id.to_s

        expect(response).to have_http_status(:ok)
        expect(response.body).to eq("[]")
      end

    end
    context 'when user checks purchases older than 2 days' do
      it 'purchasables dissapear with status :ok' do
        
        get '/profile/library?user_id='+user.id.to_s

        expect(response).to have_http_status(:ok)
        response_json = JSON.parse(response.body)
        expect(response_json.length).to eq(3)
        Timecop.travel(Time.now + 2.days) do
          get '/profile/library?user_id='+user.id.to_s
          expect(response).to have_http_status(:ok)
          response_json = JSON.parse(response.body)
          expect(response_json.length).to eq(0)
        end
      end

    end
  end
end
