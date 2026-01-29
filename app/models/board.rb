class Board < ApplicationRecord
  has_many :lists, -> { order(:position) }, dependent: :destroy

  has_many :board_memberships, dependent: :destroy
  has_many :users, through: :board_memberships
  has_many :admins, -> do
    where(board_memberships: { role: :admin })
  end, through: :board_memberships, source: :user

  validates :name, presence: true

  def admin?(user)
    board_memberships.find_by(user: user)&.admin?
  end

  def member?(user)
    board_memberships.exists?(user: user)
  end

  def add_member(user, role: :member)
    board_memberships.create(user: user, role: role)
  end
end
