class MoviesController < ApplicationController
  include ErrorHandler 

  def index
    movies = MovieService.get_movies_by_descending_creation
    if movies.present?
      render json: movies, status: :ok
    else
      render json: { error: "No movies found" }, status: :ok
    end
   
  end

  def create
    movie = Movie.new(movie_params)
    movie.save!
    MovieService.invalidate_cache
    render json: movie, status: :created
  end

  def destroy
    Movie.find(movie_params.to_i).destroy
    MovieService.invalidate_cache
  end

  private

  def movie_params
    if action_name == 'create'
      params.require(:movie).permit(:title, :plot, :purchase_options_attributes => [:price, :quality])
    elsif action_name == 'destroy'
      params.require(:id)
    end
  end
end
