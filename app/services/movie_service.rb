class MovieService

  def self.get_movies_by_descending_creation
    Movie.includes(:purchase_options).by_descending_creation
  end

end