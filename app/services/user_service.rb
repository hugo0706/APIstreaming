class UserService
  
  def self.get_library(user)
    
    purchases = user.purchases.includes(:purchasable, :purchase_option).where('expires_at > ?', Time.current).order(expires_at: :asc)
    
    library = purchases.map do |purchase|
      serializer = serializer_for(purchase.purchasable)
      {
        purchasable: serializer.new(purchase.purchasable).as_json,
        purchased_option: purchase.purchase_option,
        expires_at: purchase.expires_at
      }
    end.compact
    
  end

  private

  def self.serializer_for(purchasable)
    case purchasable.class.to_s
    when 'Movie'
      MovieSerializer
    when 'Season'
      SeasonSerializer
    end
  end

end