class AddCardsCountToLists < ActiveRecord::Migration[7.2]
  def change
    add_column :lists, :cards_count, :integer, default: 0, null: false

    reversible do |dir|
      dir.up do
        List.find_each do |list|
          List.reset_counters(list.id, :cards)
        end
      end
    end
  end
end
