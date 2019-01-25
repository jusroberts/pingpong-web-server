class AddGameTypeToPlayerRating < ActiveRecord::Migration
  def change
    add_column :player_ratings, :game_type, :integer, :default => 2
  end
end
