class Board < ApplicationRecord
  has_many :lists, -> { order(:position) }, dependent: :destroy

  validates :name, presence: true
end
