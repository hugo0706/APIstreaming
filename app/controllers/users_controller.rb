class UsersController < ApplicationController
  include ErrorHandler

  before_action :set_user_session

  def library
    library = UserService.get_library(@user)
    if library.present?
      render json: library, status: :ok
    else 
      render json: [], status: :ok
    end
  end

  private

  def set_user_session
    @user = User.find(params[:user_id].to_i)
    unless @user.present?
      render json: { error: "User not found" }, status: :not_found
    end
  end

end
