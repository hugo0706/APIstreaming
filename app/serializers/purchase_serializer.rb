class PurchaseSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :email, :title , :purchase_option, :expires_at, :created_at, :updated_at
  
  def email
    object.user.email
  end

  def title
    object.purchasable.title
  end

  def purchase_option
    {
      id: object.purchase_option.id,
      price: object.purchase_option.price,
      quality: object.purchase_option.quality
    }
  end
end 