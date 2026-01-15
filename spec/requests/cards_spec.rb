require 'rails_helper'

RSpec.describe "Cards", type: :request do
  let(:user) { User.create!(email: 'test@example.com', password: 'password123') }

  before do
    sign_in user
  end

  describe "PATCH /move" do
    let(:board) { Board.create!(name: "Test Board") }
    let(:list1) { board.lists.create!(name: "List 1", position: 1) }
    let(:list2) { board.lists.create!(name: "List 2", position: 2) }
    let!(:card1) { list1.cards.create!(title: "Card 1", body: "Body 1", position: 1) }
    let!(:card2) { list1.cards.create!(title: "Card 2", body: "Body 2", position: 2) }
    let!(:card3) { list1.cards.create!(title: "Card 3", body: "Body 3", position: 3) }

    it "moves card within same list successfully" do
      patch move_card_path(card1), params: { 
        list_id: list1.id, 
        position: 2, 
        card_ids: [card2.id, card1.id, card3.id] 
      }
      expect(response).to have_http_status(:ok)

      expect(card2.reload.position).to eq(1)
      expect(card1.reload.position).to eq(2)
      expect(card3.reload.position).to eq(3)
    end

    it "moves card to different list successfully" do
      patch move_card_path(card1), params: { 
        list_id: list2.id, 
        position: 1, 
        card_ids: [card1.id] 
      }
      expect(response).to have_http_status(:ok)

      expect(card1.reload.list_id).to eq(list2.id)
      expect(card1.reload.position).to eq(1)
    end

    it "reorders multiple cards in target list" do
      patch move_card_path(card1), params: { 
        list_id: list1.id, 
        position: 3, 
        card_ids: [card2.id, card3.id, card1.id] 
      }
      expect(response).to have_http_status(:ok)

      expect(card2.reload.position).to eq(1)
      expect(card3.reload.position).to eq(2)
      expect(card1.reload.position).to eq(3)
    end

    it "returns http not found for non-existing card" do
      patch move_card_path(999999), params: { 
        list_id: list1.id, 
        position: 1, 
        card_ids: [999999] 
      }
      expect(response).to have_http_status(:not_found)
    end

    it "returns http not found for non-existing target list" do
      patch move_card_path(card1), params: { 
        list_id: 999999, 
        position: 1, 
        card_ids: [card1.id] 
      }
      expect(response).to have_http_status(:bad_request)
    end

    it "returns http bad request for non-existing card ids in target list" do
      patch move_card_path(card1), params: { 
        list_id: list1.id, 
        position: 1, 
        card_ids: [card1.id, 999999] 
      }
      expect(response).to have_http_status(:bad_request)
    end

    it "returns http bad request for invalid card ids" do
      patch move_card_path(card1), params: { 
        list_id: list1.id, 
        position: 1, 
        card_ids: [card1.id, "invalid value"] 
      }
      expect(response).to have_http_status(:bad_request)
    end

    it "returns http bad request when list_id is missing" do
      patch move_card_path(card1), params: { 
        position: 1, 
        card_ids: [card1.id] 
      }
      expect(response).to have_http_status(:bad_request)
    end

    it "returns http bad request when position is missing" do
      patch move_card_path(card1), params: { 
        list_id: list1.id, 
        card_ids: [card1.id] 
      }
      expect(response).to have_http_status(:bad_request)
    end

    it "returns http bad request when card_ids is missing" do
      patch move_card_path(card1), params: { 
        list_id: list1.id, 
        position: 1 
      }
      expect(response).to have_http_status(:bad_request)
    end

    it "returns http bad request when card_ids is not an array" do
      patch move_card_path(card1), params: { 
        list_id: list1.id, 
        position: 1, 
        card_ids: "not an array" 
      }
      expect(response).to have_http_status(:bad_request)
    end

    it "returns http bad request when card_ids contains non-numeric values" do
      patch move_card_path(card1), params: { 
        list_id: list1.id, 
        position: 1, 
        card_ids: [card1.id, "abc", card2.id] 
      }
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe "POST /cards" do
    let(:board) { Board.create!(name: "Test Board") }
    let(:list) { board.lists.create!(name: "Test List", position: 1) }

    it "creates a new card successfully" do
      expect {
        post cards_path, params: {
          card: {
            title: "New Card",
            body: "Card body",
            list_id: list.id
          }
        }
      }.to change(Card, :count).by(1)

      expect(response).to redirect_to(board_path(board))
      
      card = Card.last
      expect(card.title).to eq("New Card")
      expect(card.body).to eq("Card body")
      expect(card.list_id).to eq(list.id)
      expect(card.position).to eq(1)
    end

    it "sets correct position for subsequent cards" do
      list.cards.create!(title: "Card 1", body: "Body 1", position: 1)
      list.cards.create!(title: "Card 2", body: "Body 2", position: 2)

      post cards_path, params: {
        card: {
          title: "Card 3",
          body: "Body 3",
          list_id: list.id
        }
      }

      expect(Card.last.position).to eq(3)
    end

    it "returns unprocessable entity when title is missing" do
      post cards_path, params: {
        card: {
          body: "Card body",
          list_id: list.id
        }
      }

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "returns bad request when list_id is invalid" do
      post cards_path, params: {
        card: {
          title: "New Card",
          body: "Card body",
          list_id: 999999
        }
      }

      expect(response).to have_http_status(:bad_request)
    end
  end

  describe "DELETE /cards/:id" do
    let(:board) { Board.create!(name: "Test Board") }
    let(:list) { board.lists.create!(name: "Test List", position: 1) }
    let!(:card) { list.cards.create!(title: "Card to Delete", body: "Body", position: 1) }

    it "deletes the card successfully" do
      expect {
        delete card_path(card)
      }.to change(Card, :count).by(-1)

      expect(response).to redirect_to(board_path(board))
    end

    it "returns not found for non-existing card" do
      delete card_path(999999)
      expect(response).to have_http_status(:not_found)
    end
  end
end
