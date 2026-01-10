class Card < ApplicationRecord
  belongs_to :list, counter_cache: true

  validates :title, presence: true
  validates :position, presence: true
end
