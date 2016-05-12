class AddDailyStatsTable < ActiveRecord::Migration
  def change
    create_table :daily_stats do |t|
      t.belongs_to :player, index: true
      t.date :day
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
    end
    # Player status calls, roll up stats per player
    add_index :daily_stats, [:player_id, :day, :has_completed_aggregation, :player_count], name: 'daily_stats_lookup'
  end
end

