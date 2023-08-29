class SeasonsController < ApplicationController
  include ErrorHandler

  def index
      seasons = SeasonService.get_seasons_desc_episodes_asc
      if seasons.present?
        render json: seasons, status: :ok
      else
        render json: { error: "No seasons found" }, status: :not_found
      end
  end

end
