class BoardsController < ApplicationController
  def show
    @board = Board.find_by(id: params[:id])
    head :not_found unless @board
  end
end
