class Purchase < ApplicationRecord
  belongs_to :user
  belongs_to :purchasable, polymorphic: true
  belongs_to :purchase_option

  validates_uniqueness_of :purchase_option_id, scope: [:purchasable_id, :purchasable_type, :user_id]
  validates :expires_at, presence: true
  
end
