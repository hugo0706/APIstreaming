module VideoContentConcern
  extend ActiveSupport::Concern

  included do
    has_many :purchase_options, as: :optionable, dependent: :destroy
    has_many :purchases, as: :purchasable

    scope :by_descending_creation, -> { order(created_at: :desc) }
    scope :by_ascending_creation, -> { order(created_at: :asc) }
  end

end