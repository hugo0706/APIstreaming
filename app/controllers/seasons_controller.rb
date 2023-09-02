class SeasonsController < ApplicationController
  include ErrorHandler

  def index
      seasons = SeasonService.get_seasons_desc_episodes_asc
      render json: seasons, status: :ok
  end

  def create
    season = Season.new(season_params)
    season.save!
    SeasonService.invalidate_cache
    render json: season, status: :created
  end

  def destroy
    Season.find(season_params.to_i).destroy
    SeasonService.invalidate_cache
  end

  private

  def season_params
    if action_name == 'create'
      params.require(:season).permit(:title, :plot,:number, :purchase_options_attributes => [:price, :quality], :episodes_attributes => [:title, :plot, :number])
    elsif action_name == 'destroy'
      params.require(:id)
    end
  end
end
