class AddWeeklyStatsTable < ActiveRecord::Migration
  def change
    create_table :weekly_stats do |t|
      t.belongs_to :player, index: true
      t.datetime :week_start
      t.datetime :week_end
      t.boolean :completed
      t.integer :player_count
      t.integer :wins
      t.integer :losses
      t.belongs_to :player, :name => 'most_defeated'
      t.belongs_to :player, :name => 'most_defeated_by'
      t.integer :average_win_margin
      t.integer :average_loss_margin
      t.integer :total_points_scored
      t.integer :total_points_scored_against
    end
    # Player status calls, roll up stats per player
    add_index :weekly_stats, [:player_id, :week_start, :completed, :player_count], name: 'weekly_stats_lookup'
  end
end

