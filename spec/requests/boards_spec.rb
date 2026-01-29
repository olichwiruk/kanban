require 'rails_helper'

RSpec.describe "Boards", type: :request do
  let(:user) { User.create!(email: 'test@example.com', password: 'password123') }
  let(:board) { Board.create!(name: "Test Board") }

  before do
    sign_in user
    board.add_member(user, role: :admin)
  end

  describe "GET /show" do

    it "returns http success" do
      get board_path(board)
      expect(response).to have_http_status(:success)
    end

    it "returns http not found for non-existing board" do
      get board_path(id: 999999)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /sort_lists" do
    let!(:list1) { board.lists.create!(name: "List 1", position: 1) }
    let!(:list2) { board.lists.create!(name: "List 2", position: 2) }
    let!(:list3) { board.lists.create!(name: "List 3", position: 3) }

    it "sorts lists successfully" do
      patch sort_lists_board_path(board), params: { lists: [list3.id, list1.id, list2.id] }
      expect(response).to have_http_status(:ok)

      expect(list3.reload.position).to eq(1)
      expect(list1.reload.position).to eq(2)
      expect(list2.reload.position).to eq(3)
    end

    it "returns http not found for non-existing board" do
      patch sort_lists_board_path(id: 999999), params: { lists: [list1.id, list2.id, list3.id] }
      expect(response).to have_http_status(:not_found)
    end

    it "returns http bad request for non-existing list ids" do
      patch sort_lists_board_path(board), params: { lists: [list1.id, 999999, list3.id] }
      expect(response).to have_http_status(:bad_request)
    end

    it "returns http bad request for invalid list ids" do
      patch sort_lists_board_path(board), params: { lists: [list1.id, "invalid value", list3.id] }
      expect(response).to have_http_status(:bad_request)
    end
  end
end
