class CatalogController < ApplicationController
  include ErrorHandler

  def index
    catalog = CatalogService.get_catalog_ordered
    if catalog.present?
      render json: catalog, status: :ok
    else
      render json: [], status: :ok
    end

  end

end
