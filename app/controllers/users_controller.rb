class UsersController < ApplicationController
  
  def library
    library = UserService.get_library(params[:user_id].to_i)
    if library.present?
      render json: library, status: :ok
    else 
      render json: { error: 'User not found' }, status: :not_found
    end
  end

end
