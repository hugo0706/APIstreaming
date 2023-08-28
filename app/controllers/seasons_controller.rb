class SeasonsController < ApplicationController

  def index
    begin
      seasons = SeasonService.get_seasons_desc_episodes_asc
      if seasons.present?
        render json: seasons, status: :ok
      else
        render json: { error: "No seasons found" }, status: :not_found
      end
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e }, status: :not_found
    rescue StandardError => e
      render json: { error: e }, status: :internal_server_error
    end
  end

end
