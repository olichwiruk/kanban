class BoardsController < ApplicationController
  def show
    @board = Board.find_by(id: params[:id])
    head :not_found unless @board
  end

  def sort_lists
    @board = Board.find_by(id: params[:id])
    return head :not_found unless @board

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
