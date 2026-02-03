class BoardsController < ApplicationController
  def index
    @boards = current_user.boards
  end

  def show
    @board = Board.includes(lists: :cards).find_by(id: params[:id])
    return head :not_found unless @board
    authorize @board
  end

  def create
    @board = Board.new(board_params)
    Board.transaction do
      if @board.save
        @board.add_member(current_user, role: :admin)

        render turbo_stream: [
          turbo_stream.before("new_board_card", partial: "boards/board_link", locals: { board: @board }),
          turbo_stream.replace("new_board_card", partial: "boards/new_link")
        ]
      else
        render :new, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    end
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

  private def board_params
    params.permit(:name)
  end
end
