class UserService

  def self.update_library(user)
    expired_purchases = user.purchases.where('expires_at < ?', Time.current)
    expired_purchases.destroy_all
  end
  
  def self.get_library(user_id)
    user = User.find(user_id)
    return [] unless user
    
    self.update_library(user)
    purchases = user.purchases.includes(:purchasable, :purchase_option).order(expires_at: :asc)

    library = purchases.map do |purchase|
      {
        purchasable: purchase.purchasable,
        purchase_option: purchase.purchase_option,
        expires_at: purchase.expires_at
      }
    end.compact
    
  end

end