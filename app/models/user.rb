class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :board_memberships, dependent: :destroy
  has_many :boards, through: :board_memberships

  def admin_of?(board)
    board_memberships.find_by(board: board)&.admin?
  end
end
