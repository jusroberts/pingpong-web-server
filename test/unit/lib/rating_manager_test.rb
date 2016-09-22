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
    player_one_start_deviation = @player_one.rating_deviation
    player_two_start_skill = @player_two.rating_skill
    player_two_start_deviation = @player_two.rating_deviation
    player_three_start_skill = @player_three.rating_skill
    player_three_start_deviation = @player_three.rating_deviation
    player_four_start_skill = @player_four.rating_skill
    player_four_start_deviation = @player_four.rating_deviation

    manager.process_game([@player_one, @player_two], 10.0, [@player_three, @player_four], -10.0)

    player_one_end_skill = @player_one.rating_skill
    player_one_end_deviation = @player_one.rating_deviation
    player_two_end_skill = @player_two.rating_skill
    player_two_end_deviation = @player_two.rating_deviation
    player_three_end_skill = @player_three.rating_skill
    player_three_end_deviation = @player_three.rating_deviation
    player_four_end_skill = @player_four.rating_skill
    player_four_end_deviation = @player_four.rating_deviation

    # Player one won, skill should go up
    assert_operator player_one_end_skill, :>, player_one_start_skill
    # Deviation should go down because this result was expected and deviation was high
    assert_operator player_one_end_deviation, :<, player_one_start_deviation
    # Player two won, skill should go up
    assert_operator player_two_end_skill, :>, player_two_start_skill
    # Deviation should go down because this result was expected and deviation was high
    assert_operator player_two_end_deviation, :<, player_two_start_deviation

    # Player three lost, skill should go down
    assert_operator player_three_end_skill, :<, player_three_start_skill
    # Deviation should go down because loss was expected, even though deviation was low
    assert_operator player_three_end_deviation, :<, player_three_start_deviation
    # Player four lost, skill should go down
    assert_operator player_four_end_skill, :<, player_four_start_skill
    # Deviation should go down because loss was expected
    assert_operator player_four_end_deviation, :<, player_four_start_deviation
  end

  def test_get_player_stats_inverse
    manager = RatingManager.new
    player_one_start_skill = @player_one.rating_skill
    player_one_start_deviation = @player_one.rating_deviation
    player_two_start_skill = @player_two.rating_skill
    player_two_start_deviation = @player_two.rating_deviation
    player_three_start_skill = @player_three.rating_skill
    player_three_start_deviation = @player_three.rating_deviation
    player_four_start_skill = @player_four.rating_skill
    player_four_start_deviation = @player_four.rating_deviation

    manager.process_game([@player_one, @player_two], -10.0, [@player_three, @player_four], 10.0)

    player_one_end_skill = @player_one.rating_skill
    player_one_end_deviation = @player_one.rating_deviation
    player_two_end_skill = @player_two.rating_skill
    player_two_end_deviation = @player_two.rating_deviation
    player_three_end_skill = @player_three.rating_skill
    player_three_end_deviation = @player_three.rating_deviation
    player_four_end_skill = @player_four.rating_skill
    player_four_end_deviation = @player_four.rating_deviation

    # Player one lost, skill should go down
    assert_operator player_one_end_skill, :<, player_one_start_skill
    # Deviation should go down even though the result was unexpected because deviation was high
    assert_operator player_one_end_deviation, :<, player_one_start_deviation
    # Player two lost, skill should go down
    assert_operator player_two_end_skill, :<, player_two_start_skill
    # Deviation should go up because this result was unexpected and deviation was low
    assert_operator player_two_end_deviation, :<, player_two_start_deviation

    # Player three won, skill should go up
    assert_operator player_three_end_skill, :>, player_three_start_skill
    # Deviation should go up because win was unexpected, and deviation was low
    assert_operator player_three_end_deviation, :<, player_three_start_deviation
    # Player four won, skill should go up
    assert_operator player_four_end_skill, :>, player_four_start_skill
    # Deviation should go down because deviation was high, even though loss was unexpected
    assert_operator player_four_end_deviation, :<, player_four_start_deviation
  end
end