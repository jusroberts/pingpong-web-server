class AddRatingDifferential < ActiveRecord::Migration
  def change
    add_column :game_histories, :skill_change, :float
    add_column :game_histories, :deviation_change, :float
  end
end
