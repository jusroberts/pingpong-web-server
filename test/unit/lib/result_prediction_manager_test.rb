require "minitest/autorun"
require 'test_helper'

class ResultPredictionManagerTest < ActiveSupport::TestCase
  def setup
    @player_one = Player.where(rfid_hash: '94ae910e6492eb9ea8c019b63961d254ee9b51124ae910e6492eb9ea8c019b641').last
    @player_two = Player.where(rfid_hash: '94ae910e6492eb9ea8c019b63961d254ee9b51124ae910e6492eb9ea8c019b644').last
    @player_three = Player.where(rfid_hash: '94ae910e6492eb9ea8c019b63961d254ee9b51124ae910e6492eb9ea8c019b645').last
    @player_four = Player.where(rfid_hash: '94ae910e6492eb9ea8c019b63961d254ee9b51124ae910e6492eb9ea8c019b646').last
  end

  def test_predict_result
    manager = ResultPredictionManager.new

    @player_one.rating_skill = 30.0
    player_one_start_skill = @player_one.rating_skill
    @player_two.rating_skill = 28.0
    @player_three.rating_skill = 25.0
    @player_four.rating_skill = 22.0

    predicted_winning_team, predicted_score = manager.predict_result([@player_one, @player_two], [@player_three, @player_four])

    assert_equal(@player_one.rating_skill, player_one_start_skill, 'Skills should not have changed')
    assert_equal([@player_one, @player_two], predicted_winning_team)
    assert_operator(predicted_score, :>, 2)
  end
end