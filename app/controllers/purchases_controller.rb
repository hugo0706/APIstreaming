class PurchasesController < ApplicationController

  def purchase
    params = purchase_params
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

  def purchase_params
    begin
      params.require(:purchase).permit(:purchasable_type, :purchasable_id, :user_id, :purchase_option_id)
    rescue ActionController::ParameterMissing => e
      render json: { error: e.message }, status: :bad_request
    end
  end
end
