class BoardMembership < ApplicationRecord
  belongs_to :user
  belongs_to :board

  enum :role, { member: 0, admin: 1 }

  validates :user_id, uniqueness: { scope: :board_id }
  validates :role, presence: true

  scope :admins, -> { where(role: :admin) }
  scope :members, -> { where(role: :member) }
end
