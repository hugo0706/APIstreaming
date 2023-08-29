class PurchasesController < ApplicationController
  include ErrorHandler

  before_action :validate_params, only: [:purchase]
  before_action :update_library, only: [:purchase]

  def purchase
    valid_params = params[:purchase]
    case valid_params.delete(:purchasable_type).capitalize
    when "Movie"
      purchase = MovieService.purchase_movie valid_params
      render json: purchase, status: :created   
    when "Season"
      purchase = SeasonService.purchase_season valid_params
      render json: purchase, status: :created   
    else
      raise ActionController::ParameterMissing.new("purchasable_type value not valid")
    end
  end

  private

  def validate_params
    params.require(:purchase)
    %i[purchasable_type purchasable_id user_id purchase_option_id].each do |key|
      raise ActionController::ParameterMissing.new(key) unless params[:purchase].key?(key)
    end
    params[:purchase] = params.require(:purchase).permit(:purchasable_type, :purchasable_id, :user_id, :purchase_option_id)
  end

  def update_library
    user = User.find(params[:purchase][:user_id].to_i)
    UserService.update_library(user)
  end

end
