class CardPolicy < ApplicationPolicy
  attr_reader :user, :card

  def initialize(user, card)
    @user = user
    @card = card
  end

  def show?
    card.list.board.member?(user)
  end

  def new?
    create?
  end

  def create?
    card.list.board.member?(user)
  end

  def destroy?
    card.list.board.member?(user)
  end

  def move?
    card.list.board.member?(user)
  end
end
