class CardsController < ApplicationController
  def show
    @card = Card.eager_load(list: :board).find_by(id: params[:id])
    return head :not_found unless @card
    authorize @card

    render partial: 'cards/show', locals: { card: @card }
  end

  def new
    list = List.eager_load(:board).find_by(id: params[:list_id])
    return head :bad_request unless list

    @card = Card.new(list: list)
    authorize @card

    render partial: 'cards/new', locals: { card: @card }
  end

  def create
    list = List.find_by(id: card_params[:list_id])
    return head :bad_request unless list

    @card = list.cards.build(card_params.except(:list_id))
    authorize @card
    @card.position = list.cards.maximum(:position).to_i + 1

    if @card.save
      redirect_to board_path(list.board)
    else
      render partial: 'cards/new', locals: { card: @card }, status: :unprocessable_content
    end
  end

  def destroy
    @card = Card.eager_load(list: :board).find_by(id: params[:id])
    return head :not_found unless @card
    authorize @card

    board = @card.list.board
    @card.destroy
    redirect_to board_path(board)
  end

  def move
    return head :bad_request unless move_params_valid?

    @card = Card.eager_load(list: :board).find_by(id: params[:id])
    @target_list = List.eager_load(:board).find_by(id: params[:list_id])
    return head :not_found unless @card && @target_list
    authorize @card
    @source_list = @card.list
    unless @source_list.board_id == @target_list.board_id
      return head :unprocessable_entity
    end

    transaction_successful = false
    Card.transaction do
      @card.update!(list_id: @target_list.id, position: params[:position])

      card_ids = params[:card_ids].map(&:to_i)
      unless @target_list.cards.where(id: card_ids).count == card_ids.size
        raise ActiveRecord::Rollback
      end

      card_ids.each_with_index do |id, i|
        Card.where(id: id).update_all(position: i + 1)
      end
      transaction_successful = true
    end
    return head :bad_request unless transaction_successful

    respond_to do |format|
      format.turbo_stream
      format.html { head :ok }
    end
  rescue ActionController::ParameterMissing
    head :bad_request
  end

  private def card_params
    params.require(:card).permit(:title, :body, :list_id)
  end

  private def move_params_valid?
    params[:list_id].present? &&
      params[:position].present? &&
      params[:card_ids].is_a?(Array) &&
      params[:card_ids].all? { |id| id.to_s.match?(/^\d+$/) }
  end
end
