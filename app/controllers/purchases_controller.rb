class PurchasesController < ApplicationController
  before_action :validate_params, only: [:purchase]

  rescue_from StandardError, with: :handle_internal_error
  rescue_from ActionController::ParameterMissing, with: :handle_bad_request
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :handle_unprocessable_entity

  def purchase
    valid_params = params[:purchase]
    case valid_params.delete(:purchasable_type).capitalize
    when "Movie"
      purchase = MovieService.purchase_movie valid_params
      render json: purchase, status: :created   
    when "Season"
      SeasonService.purchase_season valid_params
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

  def handle_bad_request(e)
    render json: { error: e.message }, status: :bad_request
  end

  def handle_not_found(e)
    render json: { error: e.message }, status: :not_found
  end

  def handle_unprocessable_entity(e)
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def handle_internal_error(e)
    render json: { error: e.message }, status: :internal_server_error
  end
  

end
