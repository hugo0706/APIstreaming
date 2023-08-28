class MoviesController < ApplicationController

  def index
    begin
      movies = MovieService.get_movies_by_descending_creation
      if movies.present?
        render json: movies, status: :ok
      else
        render json: { message: "No movies found" }, status: :not_found
      end
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e }, status: :not_found
    rescue StandardError => e
      render json: { error: e }, status: :internal_server_error
    end
  end

end
