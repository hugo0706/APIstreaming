class EpisodeSerializer < ActiveModel::Serializer
  attributes :type, :id, :title,:number,  :plot, :created_at

  def type
    object.class.name.downcase
  end
end
