class SeasonSerializer < ActiveModel::Serializer
  attributes :id, :type, :title, :number, :plot , :created_at, :updated_at, :episodes, :purchase_options

  has_many :episodes

  def type
    object.class.name.downcase
  end

end