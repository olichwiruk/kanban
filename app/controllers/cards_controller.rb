class CardsController < ApplicationController
  def move
    return head :bad_request unless move_params_valid?

    @card = Card.find_by(id: params[:id])
    return head :not_found unless @card

    target_list = List.find_by(id: params[:list_id])
    return head :bad_request unless target_list

    @card.update(list_id: target_list.id, position: params[:position])

    card_ids = move_params[:card_ids].map(&:to_i)
    valid_card_ids = target_list.cards.where(id: card_ids).pluck(:id)
    return head :bad_request unless valid_card_ids.tally == card_ids.tally

    card_ids.each_with_index do |id, i|
      Card.where(id: id).update_all(position: i + 1)
    end

    head :ok
  rescue ActionController::ParameterMissing
    head :bad_request
  end

  private def move_params
    params.permit(:list_id, :position, card_ids: [])
  end

  private def move_params_valid?
    params[:list_id].present? &&
      params[:position].present? &&
      params[:card_ids].is_a?(Array) &&
      params[:card_ids].all? { |id| id.to_s.match?(/^\d+$/) }
  end
end
