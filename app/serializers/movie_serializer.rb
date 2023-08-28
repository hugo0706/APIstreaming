class MovieSerializer < ActiveModel::Serializer
  attributes :id, :title, :plot, :created_at, :updated_at, :purchase_options

  
  def purchase_options
 
    object.purchase_options.map do |purchase_option|
      {
        id: purchase_option.id,
        price: purchase_option.price,
        quality: purchase_option.quality
      }
    end
  end
end
