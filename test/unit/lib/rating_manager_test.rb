require "minitest/autorun"
require 'test_helper'

class StatsManagerTest < ActiveSupport::TestCase
  def setup
    @player_one = Player.where(rfid_hash: '94ae910e6492eb9ea8c019b63961d254ee9b51124ae910e6492eb9ea8c019b641').last
    @player_two = Player.where(rfid_hash: '94ae910e6492eb9ea8c019b63961d254ee9b51124ae910e6492eb9ea8c019b644').last
    @player_three = Player.where(rfid_hash: '94ae910e6492eb9ea8c019b63961d254ee9b51124ae910e6492eb9ea8c019b645').last
    @player_four = Player.where(rfid_hash: '94ae910e6492eb9ea8c019b63961d254ee9b51124ae910e6492eb9ea8c019b646').last
  end

  def test_get_player_stats
    manager = RatingManager.new
    player_one_start_skill = @player_one.rating_skill
    player_one_start_confidence = @player_one.rating_confidence
    player_three_start_skill = @player_three.rating_skill
    player_three_start_confidence = @player_three.rating_confidence

    manager.process_game([@player_one, @player_two], 10.0, [@player_three, @player_four], -10.0)

    player_one_end_skill = @player_one.rating_skill
    player_one_end_confidence = @player_one.rating_confidence
    player_three_end_skill = @player_three.rating_skill
    player_three_end_confidence = @player_three.rating_confidence

    # Player one won, skill should go up
    assert_operator player_one_end_skill, :>, player_one_start_skill
    # Player one was expected to win, confidence should go up
    # TODO: what the hell does deviation mean in this context anyway?
    # assert_operator player_one_end_confidence, :>, player_one_start_confidence

    # Player three lost, skill should go down
    assert_operator player_three_end_skill, :<, player_three_start_skill
  end
end