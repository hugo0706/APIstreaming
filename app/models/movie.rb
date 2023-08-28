class Movie < ApplicationRecord

  include VideoContentConcern

  validates :title, presence: true
  validates :plot, presence: true
end
