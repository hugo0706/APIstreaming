class PurchaseOption < ApplicationRecord
  belongs_to :optionable, polymorphic: true
  has_many :purchases, dependent: :destroy

  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :quality, presence: true, inclusion: { in: %w[HD SD] }
end
