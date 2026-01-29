class BoardPolicy < ApplicationPolicy
  attr_reader :user, :board

  def initialize(user, board)
    @user = user
    @board = board
  end

  def show?
    board.member?(user)
  end

  def sort_lists?
    board.member?(user)
  end
end
