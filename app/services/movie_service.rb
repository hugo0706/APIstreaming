class MovieService

  def self.get_movies_by_descending_creation
    
    Rails.cache.fetch('movies_by_descending_creation') do
      Movie.includes(:purchase_options).by_descending_creation
    end 

  end

  def self.invalidate_cache
    Rails.cache.delete('movies_by_descending_creation')
    get_movies_by_descending_creation
  end

  def self.purchase_movie(params)
    begin
      purchase_option = params[:purchase_option_id].to_i
      movie = Movie.includes(:purchase_options).find(params[:purchasable_id].to_i)
      purchase_option = movie.purchase_options.find_by(id: purchase_option)
      raise ActiveRecord::RecordNotFound if purchase_option.nil?
      Purchase.transaction do
        Purchase.create!(**params, purchasable_type: "Movie", expires_at: Time.now + 2.days)
      end

    rescue ActiveRecord::RecordNotFound => e
      if purchase_option.nil?
        raise ActiveRecord::RecordNotFound.new("Purchase option not found")
      else
        raise ActiveRecord::RecordNotFound.new("Movie not found")
      end
    end
  end
end