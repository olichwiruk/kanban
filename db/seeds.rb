# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

board = Board.create!(name: "First Board")
%w[Backlog In-Progress Done].each_with_index do |state, index|
  list = board.lists.create!(name: state, position: index)

  3.times do |n|
    list.cards.create!(
      title: "#{state} Task #{n + 1}",
      body: "Description for #{state.downcase} task #{n + 1}",
      position: n + 1
    )
  end
end

Board.create!(name: "Empty Board")
