class PurchaseOption < ApplicationRecord
  belongs_to :optionable, polymorphic: true

  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :quality, presence: true, inclusion: { in: %w[HD SD] }
end
