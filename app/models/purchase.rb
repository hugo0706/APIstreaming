class Purchase < ApplicationRecord
  belongs_to :user
  belongs_to :purchasable, polymorphic: true
  belongs_to :purchase_option
end
