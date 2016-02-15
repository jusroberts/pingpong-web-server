require "minitest/autorun"

class GameLogicTest < Minitest::Test
  def setup

  end

  #Game_Over

  def test_game_not_over
    assert_equal(false, GameLogic.new(0,0).game_over?)
  end

  def test_game_over_team_b
    assert_equal(true, GameLogic.new(0,21).game_over?)
  end

  def test_game_over_team_a
    assert_equal(true, GameLogic.new(21,0).game_over?)
  end

  #Showable scores

  def test_showable_regular_score
    logic = GameLogic.new(0, 0)
    assert_equal(0, logic.showable_team_a_score)
    assert_equal(0, logic.showable_team_b_score)
  end

  def test_showable_game_point_a
    logic = GameLogic.new(20, 0)
    assert_equal('G', logic.showable_team_a_score)
    assert_equal(0, logic.showable_team_b_score)
  end

  def test_showable_game_point_b
    logic = GameLogic.new(0, 20)
    assert_equal(0, logic.showable_team_a_score)
    assert_equal('G', logic.showable_team_b_score)
  end

  def test_showable_deuce
    logic = GameLogic.new(25, 25)
    assert_equal('D', logic.showable_team_a_score)
    assert_equal('D', logic.showable_team_b_score)
  end

  def test_showable_advantage_a
    logic = GameLogic.new(21, 20)
    assert_equal('ADV', logic.showable_team_a_score)
    assert_equal('-', logic.showable_team_b_score)
  end

  def test_showable_advantage_b
    logic = GameLogic.new(20, 21)
    assert_equal('-', logic.showable_team_a_score)
    assert_equal('ADV', logic.showable_team_b_score)
  end

  def test_showable_winner_a
    logic = GameLogic.new(22, 20)
    assert_equal('W', logic.showable_team_a_score)
    assert_equal('L', logic.showable_team_b_score)
  end

  def test_showable_winner_b
    logic = GameLogic.new(20, 22)
    assert_equal('L', logic.showable_team_a_score)
    assert_equal('W', logic.showable_team_b_score)
  end


end