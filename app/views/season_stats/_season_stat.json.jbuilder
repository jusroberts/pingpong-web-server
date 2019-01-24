json.extract! season_stat, :id, :player_id, :season_id, :has_completed_aggregation, :player_count, :wins, :losses, :most_defeated_player_id, :most_defeated_by_player_id, :average_win_margin, :average_loss_margin, :total_points_scored, :total_points_scored_against, :created_at, :updated_at
json.url season_stat_url(season_stat, format: :json)
