require 'time'
class StatsManager
  def initialize
  end

  def run_game_stats

  end

  def run_daily_stats_for_player

  end

  def run_weekly_stats_for_player

  end

  # @param player_id [Int]
  # @return [PlayerStats]
  def get_player_stats(player_id, player_count)
    player_stats = PlayerStats.new(player_count)
    # Pull all player weekly stats and aggregate
    # @param weekly_stat [WeeklyStats]
    WeeklyStat.where(player_id: player_id, player_count: player_count).all.each do |weekly_stat|
      player_stats.process_stat_entry!(weekly_stat, 7)
    end

    # Pull daily stats in progress and aggregate
    DailyStat.where(player_id: player_id, completed: false).all.each do |daily_stat|
      player_stats.process_stat_entry!(daily_stat, 1)
    end

    player_stats
  end
end