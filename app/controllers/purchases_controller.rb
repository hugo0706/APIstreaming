class PurchasesController < ApplicationController
  include ErrorHandler

  def purchase
    valid_params = validate_params
    purchase = Purchase.find_by(valid_params)
    if purchase.present?
      purchase_existing(purchase)
    else
      case valid_params[:purchasable_type].capitalize
      when "Movie"
        purchase = MovieService.purchase_movie valid_params
      when "Season"
        purchase = SeasonService.purchase_season valid_params
      else
        render json: { error: "Invalid purchasable type" }, status: :unprocessable_entity
      end

      if purchase.persisted?
        render json: purchase, status: :created
      else
        render json: { error: purchase.errors}, status: :unprocessable_entity
      end
    end
  end

  private

 
  def validate_params
    params.require(:purchase).require(%i[purchasable_type purchasable_id user_id purchase_option_id])
    params.require(:purchase).permit(:purchasable_type, :purchasable_id, :user_id, :purchase_option_id)
  end

  def purchase_existing(purchase)
    if purchase.expired?
      purchase.update(expires_at: Time.now + 2.days)
      render json: purchase, status: :created
    else
      render json: { error: "Purchase option has already been taken" }, status: :unprocessable_entity
    end

  end
end
