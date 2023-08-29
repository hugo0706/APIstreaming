class Season < ApplicationRecord

  include VideoContentConcern
  
  has_many :episodes, dependent: :destroy

  accepts_nested_attributes_for :episodes

  validates :title, presence: true
  validates :plot, presence: true
  validates :number, presence: true, numericality: { only_integer: true, greater_than: 0 }
end
