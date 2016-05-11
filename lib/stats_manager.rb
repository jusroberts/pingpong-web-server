require 'time'
class StatsManager
  def initialize
  end

  # @return [Array<DailyStat>]
  def run_game_stats
    # Get all player ids in the game

    # Run daily stats for each player

    # Save updated stats

  end

  def run_daily_stats_for_player

  end

  def run_weekly_stats_for_player(player_id, player_count)
    # Get all unfinished daily stats for this player
    all_daily_stats = DailyStat.where(player_id: player_id, has_completed_aggregation: false, player_count: player_count).all

    # Ruby considers Monday to be the first day of the week, for what it's worth
    # Break up by weeks
    daily_stats_by_week = {}
    all_daily_stats.each do |daily_stat|
      week_start = daily_stat.day.at_beginning_of_week.to_s
      unless daily_stats_by_week.has_key?(week_start)
        daily_stats_by_week[week_start] = []
      end
      daily_stats_by_week[week_start] << daily_stat
    end

    # For each week, grab all daily stats for that week regardless of completion (in case something went wrong)
    daily_stats_by_week.map do |week_start, daily_stats|
      week_start_date = Date.parse(week_start)
      all_daily_stats = DailyStat.where(player_id: player_id, player_count: player_count, day: week_start_date...(week_start_date.advance(:weeks => 1))).all.to_a
      daily_stats_by_week[week_start] = all_daily_stats
    end

    # Aggregate stats
    daily_stats_by_week.each do |week_start, daily_stats|
      week_start_date = Date.parse(week_start)
      aggregate = PlayerStats.new(player_count)
      daily_stats.each do |daily_stat|
        aggregate.process_stat_entry!(daily_stat, 1)
        # Mark daily stats as completed
        daily_stat.has_completed_aggregation = true
        daily_stat.save
      end
      # Transform and save weekly stats
      weekly_stat = aggregate.to_weekly_stat
      weekly_stat.player_id = player_id
      weekly_stat.week_start = week_start_date
      weekly_stat.has_completed_aggregation = true
      weekly_stat.save
    end

  end

  # @param player_id [Int]
  # @return [PlayerStats]
  def get_player_stats(player_id, player_count)
    player_stats = PlayerStats.new(player_count)
    # Pull all player weekly stats and aggregate
    # @param weekly_stat [WeeklyStats]
    WeeklyStat.where(player_id: player_id, player_count: player_count, has_completed_aggregation: false).all.each do |weekly_stat|
      player_stats.process_stat_entry!(weekly_stat, 7)
    end

    # Pull daily stats in progress and aggregate
    DailyStat.where(player_id: player_id, has_completed_aggregation: false).all.each do |daily_stat|
      player_stats.process_stat_entry!(daily_stat, 1)
    end

    player_stats
  end
end