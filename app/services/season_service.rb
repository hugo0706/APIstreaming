class SeasonService

  def self.get_seasons_desc_episodes_asc
    
    Season.eager_load(:episodes).includes(:purchase_options)
                                .merge(Episode.by_ascending_number)
                                .by_descending_creation

  end

end