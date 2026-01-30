class AddCommentsCountToCards < ActiveRecord::Migration[7.2]
  def change
    add_column :cards, :comments_count, :integer, default: 0, null: false

    reversible do |dir|
      dir.up do
        Card.find_each do |card|
          Card.reset_counters(card.id, :comments)
        end
      end
    end
  end
end
