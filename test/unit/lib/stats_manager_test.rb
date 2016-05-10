require "minitest/autorun"
require 'test_helper'

class StatsManagerTest < Minitest::Test
  def setup
    # @player_one = Player.where(rfid_hash: '94ae910e6492eb9ea8c019b63961d254ee9b51124ae910e6492eb9ea8c019b641').last
    @player_one = Player.last
  end

  #Game_Over

  def test_get_player_stats_two_days
    manager = StatsManager.new
    manager.get_player_stats(@player_one.id, 2)
  end

end