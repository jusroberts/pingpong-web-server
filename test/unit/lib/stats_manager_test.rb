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
    weekly_stats = manager.run_weekly_stats_for_player(@player_one.id, 2)
    # assert_equal(7, player_stat.wins)
    # assert_equal(7, player_stat.losses)
    # assert_equal(7, player_stat.average_win_margin)
    # assert_in_delta(10.333, player_stat.average_loss_margin)
    # assert_equal(401, player_stat.total_points_scored)
    # assert_equal(602, player_stat.total_points_scored_against)
    # assert_equal(3, player_stat.total_period_days)
  end

end