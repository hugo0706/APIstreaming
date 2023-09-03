class MovieService

  def self.get_movies_by_descending_creation
    
    Rails.cache.fetch('movies_by_descending_creation') do
      Movie.includes(:purchase_options).by_descending_creation
    end 

  end

  def self.invalidate_cache
    Rails.cache.delete('movies_by_descending_creation')
  end

  def self.purchase_movie(params)
    Purchase.create(**params)
  end
end