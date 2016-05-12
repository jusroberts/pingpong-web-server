require "minitest/autorun"
require 'test_helper'

class StatsManagerTest < ActiveSupport::TestCase
  def setup
    @player_one = Player.where(rfid_hash: '94ae910e6492eb9ea8c019b63961d254ee9b51124ae910e6492eb9ea8c019b641').last
  end

  def test_get_player_stats
    manager = StatsManager.new
    player_stat = manager.get_player_stats(@player_one.id, 2)
    assert_equal(8, player_stat.wins)
    assert_equal(8, player_stat.losses)
    assert_equal(5.5, player_stat.average_win_margin)
    assert_in_delta(8, player_stat.average_loss_margin)
    assert_equal(402, player_stat.total_points_scored)
    assert_equal(603, player_stat.total_points_scored_against)
    assert_equal(4, player_stat.total_period_days)
  end

  def test_run_weekly_stats
    manager = StatsManager.new
    manager.run_weekly_stats_for_player(@player_one.id, 2)
    weekly_stats = {}
    # @type weekly_stat [WeeklyStat]
    WeeklyStat.all.each do |weekly_stat|
      weekly_stats[weekly_stat.week_start.to_s] = weekly_stat
    end

    assert_equal(true, weekly_stats.has_key?('2016-05-02'))
    # @type weekly_stat [WeeklyStat]
    weekly_stat = weekly_stats['2016-05-02']
    assert_equal(3, weekly_stat.wins)
    assert_equal(4, weekly_stat.losses)
    assert_equal(1.5, weekly_stat.average_win_margin)
    assert_in_delta(2, weekly_stat.average_loss_margin)
    assert_equal(5, weekly_stat.total_points_scored)
    assert_equal(6, weekly_stat.total_points_scored_against)

    assert_equal(true, weekly_stats.has_key?('2016-05-09'))
    # @type weekly_stat [WeeklyStat]
    weekly_stat = weekly_stats['2016-05-09']
    assert_equal(7, weekly_stat.wins)
    assert_equal(7, weekly_stat.losses)
    assert_equal(7, weekly_stat.average_win_margin)
    assert_in_delta(10.333, weekly_stat.average_loss_margin)
    assert_equal(401, weekly_stat.total_points_scored)
    assert_equal(602, weekly_stat.total_points_scored_against)
  end
end