require 'rails_helper'

RSpec.describe "Boards", type: :request do
  describe "GET /show" do
    let(:board) { Board.create!(name: "Test Board") }

    it "returns http success" do
      get board_path(board)
      expect(response).to have_http_status(:success)
    end

    it "returns http not found for non-existing board" do
      get board_path(id: 999999)
      expect(response).to have_http_status(:not_found)
    end
  end
end
