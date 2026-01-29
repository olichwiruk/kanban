class BoardsController < ApplicationController
  def index
    @boards = current_user.boards
  end

  def show
    @board = Board.includes(lists: :cards).find_by(id: params[:id])
    return head :not_found unless @board
    authorize @board
  end

  def sort_lists
    @board = Board.find_by(id: params[:id])
    return head :not_found unless @board
    authorize @board

    list_ids = sort_lists_params
    valid_list_ids = @board.lists.all.pluck(:id)
    return head :bad_request unless valid_list_ids.tally == list_ids.tally

    list_ids.each_with_index do |id, i|
      List.where(id: id).update_all(position: i + 1)
    end

    head :ok
  end

  private def sort_lists_params
    params.require(:lists).map(&:to_i)
  end
end
