class Purchase < ApplicationRecord
  belongs_to :user
  belongs_to :purchasable, polymorphic: true
  belongs_to :purchase_option

  validates_uniqueness_of :purchase_option_id, scope: [:purchasable_id, :purchasable_type, :user_id]
  validates :expires_at, presence: true
  before_validation :set_default_expires_at, on: :create

  private

  def set_default_expires_at
    binding.irb
    self.expires_at ||= Time.now + 2.days
  end
  
end
