class SeasonService

  def self.get_seasons_desc_episodes_asc
    
    Rails.cache.fetch('seasons_desc_episodes_asc') do
      Season.eager_load(:episodes).includes(:purchase_options)
                                  .merge(Episode.by_ascending_number)
                                  .by_descending_creation
    end
    
  end

end