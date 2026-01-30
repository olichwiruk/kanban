class Card < ApplicationRecord
  belongs_to :list, counter_cache: true
  has_many :comments, dependent: :destroy

  validates :title, presence: true
  validates :position, presence: true
end
