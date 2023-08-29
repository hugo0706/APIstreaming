class SeasonService

  def self.get_seasons_desc_episodes_asc
    
    Rails.cache.fetch('seasons_desc_episodes_asc') do
      Season.eager_load(:episodes).includes(:purchase_options)
                                  .merge(Episode.by_ascending_number)
                                  .by_descending_creation
    end
    
  end

  def self.purchase_season(params)
    begin
      purchase_option = params[:purchase_option_id].to_i
      season = Season.includes(:purchase_options,:episodes).find(params[:purchasable_id].to_i)
      purchase_option = season.purchase_options.find_by(id: purchase_option)
      raise ActiveRecord::RecordNotFound if purchase_option.nil?
      Purchase.transaction do
        Purchase.create!(**params, purchasable_type: "Season", expires_at: Time.now + 2.days)
      end

    rescue ActiveRecord::RecordNotFound => e
      if purchase_option.nil?
        raise ActiveRecord::RecordNotFound.new("Purchase option not found")
      else
        raise ActiveRecord::RecordNotFound.new("Season not found")
      end
    end
  end

end