class List < ApplicationRecord
  belongs_to :board
  has_many :cards, -> { order(:position) }, dependent: :destroy

  validates :position, presence: true
end
