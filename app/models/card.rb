class Card < ApplicationRecord
  belongs_to :list

  validates :title, presence: true
  validates :position, presence: true
end
