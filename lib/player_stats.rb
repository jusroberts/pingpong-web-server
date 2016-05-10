class PlayerStats
  def initialize(player_count)
    @player_count = player_count
    @wins = 0
    @losses = 0
    @most_defeated = nil
    @most_defeated_by = nil
    @average_win_margin = 0
    @average_loss_margin = 0
    @total_points_scored = 0
    @total_points_scored_against = 0
    @total_period_days = 0
  end

  # @param stat_entry [DailyStats, WeeklyStats]
  # @param period_days [Number]
  def process_stat_entry!(stat_entry, period_days)
    if stat_entry.player_count != @player_count
      raise "Failed to process stat entry with player count #{stat_entry.player_count} for stat aggregation with player count #{@player_count}"
    end

    @wins += stat_entry.wins
    @losses += stat_entry.losses
    @total_points_scored += stat_entry.total_points_scored
    @total_points_scored_against += stat_entry.total_points_scored_against

    increment_weighted_stat(stat_entry.average_win_margin, 'average_win_margin', period_days)
    increment_weighted_stat(stat_entry.average_loss_margin, 'average_loss_margin', period_days)

    @total_period_days += period_days
  end

  # @param new_stat_value [Number]
  # @param stat_name [String]
  # @param period_days [Number]
  private def increment_weighted_stat!(new_stat_value, stat_name, period_days)
    variable_name = "@#{stat_name}"
    current_stat_value = instance_variable_get(variable_name)
    instance_variable_set("@#{stat_name}", ((new_stat_value * period_days) + (current_stat_value * @total_period_days)) / (period_days + @total_period_days))
  end
end
