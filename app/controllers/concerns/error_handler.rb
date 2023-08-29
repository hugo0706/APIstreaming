module ErrorHandler 
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError, with: :handle_internal_error
    rescue_from ActionController::ParameterMissing, with: :handle_bad_request
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :handle_unprocessable_entity
    rescue_from ActionController::RoutingError, with: :handle_not_found
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