class User < ApplicationRecord

  validates :email, presence: true, uniqueness: true
  has_many :purchases, dependent: :destroy

end
