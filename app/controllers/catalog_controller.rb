class CatalogController < ApplicationController
  include ErrorHandler

  def index
    catalog = CatalogService.get_catalog_ordered
    render json: catalog, status: :ok
  end

end
