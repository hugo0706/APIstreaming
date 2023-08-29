class PurchasesController < ApplicationController
  before_action :validate_params, only: [:purchase]

  rescue_from ActionController::ParameterMissing, with: :handle_bad_request

  def purchase

    case params.delete(:purchasable_type).capitalize
    when "Movie"
      begin
        purchase = MovieService.purchase_movie params
        render json: purchase, status: :created
      rescue ActiveRecord::RecordNotFound => e
        render json: { error: e.message }, status: :not_found
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.message }, status: :unprocessable_entity
      rescue StandardError => e
        render json: { error: e.message }, status: :internal_server_error
      end
      
    when "Season"
      SeasonService.purchase_season params
    else
      render json: { error: "Content type not found" }, status: :not_found
    end
  end


  private

  def validate_params
    params.require(:purchase)
    %i[purchasable_type purchasable_id user_id purchase_option_id].each do |key|
      raise ActionController::ParameterMissing.new(key) unless params[:purchase].key?(key)
    end
    params.permit(:purchasable_type, :purchasable_id, :user_id, :purchase_option_id)
  end

  def handle_bad_request(exception)
    render json: { error: exception.message }, status: :bad_request
  end
  

end
