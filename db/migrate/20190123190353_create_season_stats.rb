class CreateSeasonStats < ActiveRecord::Migration
  def change
    create_table :season_stats do |t|
      t.integer :player_id
      t.integer :season_id
      t.boolean :has_completed_aggregation
      t.integer :player_count
      t.integer :wins
      t.integer :losses
      t.integer :most_defeated_player_id
      t.integer :most_defeated_by_player_id
      t.float :average_win_margin
      t.float :average_loss_margin
      t.integer :total_points_scored
      t.integer :total_points_scored_against

      t.timestamps null: false
    end
  end
end
