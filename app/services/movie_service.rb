class MovieService

  def self.get_movies_by_descending_creation
    
    Rails.cache.fetch('movies_by_descending_creation') do
      Movie.includes(:purchase_options).by_descending_creation
    end 

  end

end