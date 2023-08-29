class MoviesController < ApplicationController
  include ErrorHandler 

  def index
    movies = MovieService.get_movies_by_descending_creation
    if movies.present?
      render json: movies, status: :ok
    else
      render json: { error: "No movies found" }, status: :not_found
    end
   
  end

end
