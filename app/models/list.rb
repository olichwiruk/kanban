class List < ApplicationRecord
  belongs_to :board

  validates :position, presence: true
end
