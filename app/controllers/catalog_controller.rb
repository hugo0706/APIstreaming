class CatalogController < ApplicationController

  def index
    
    begin
      catalog = CatalogService.get_catalog_ordered
      render json: catalog, status: :ok
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e }, status: :not_found
    rescue StandardError => e
      render json: { error: e }, status: :internal_server_error
    end 

  end

end
