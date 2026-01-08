class Card < ApplicationRecord
  belongs_to :list

  validates :position, presence: true
end
