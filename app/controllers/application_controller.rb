class ApplicationController < ActionController::API
  def handle_routing_error
    render json: { error: 'Resource Not Found' }, status: :not_found
  end
end
