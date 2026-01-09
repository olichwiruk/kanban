class CardsController < ApplicationController
  def show
    @card = Card.find_by(id: params[:id])
    return head :not_found unless @card

    render partial: 'cards/show', locals: { card: @card }
  end

  def new
    list = List.find_by(id: params[:list_id])
    return head :bad_request unless list

    @card = Card.new(list: list)
    render partial: 'cards/new', locals: { card: @card }
  end

  def create
    list = List.find_by(id: card_params[:list_id])
    return head :bad_request unless list

    @card = list.cards.build(card_params.except(:list_id))
    @card.position = list.cards.maximum(:position).to_i + 1

    if @card.save
      redirect_to board_path(list.board)
    else
      render partial: 'cards/new', locals: { card: @card }, status: :unprocessable_content
    end
  end

  def move
    return head :bad_request unless move_params_valid?

    @card = Card.find_by(id: params[:id])
    return head :not_found unless @card

    target_list = List.find_by(id: params[:list_id])
    return head :bad_request unless target_list

    @card.update(list_id: target_list.id, position: params[:position])

    card_ids = params[:card_ids].map(&:to_i)
    valid_card_ids = target_list.cards.where(id: card_ids).pluck(:id)
    return head :bad_request unless valid_card_ids.tally == card_ids.tally

    card_ids.each_with_index do |id, i|
      Card.where(id: id).update_all(position: i + 1)
    end

    head :ok
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
