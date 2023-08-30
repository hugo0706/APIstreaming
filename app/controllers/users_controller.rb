class UsersController < ApplicationController
  include ErrorHandler

  def library
    library = UserService.get_library(params[:user_id].to_i)
    if library.present?
      render json: library, status: :ok
    else 
      render json: [], status: :ok
    end
  end

end
