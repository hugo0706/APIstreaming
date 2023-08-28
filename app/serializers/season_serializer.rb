class SeasonSerializer < ActiveModel::Serializer
  attributes :id , :title , :plot , :number, :episodes, :purchase_options, :created_at
end