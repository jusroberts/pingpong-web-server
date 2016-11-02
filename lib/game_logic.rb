require 'time'
class GameLogic
  PENULTIMATE_SCORE = 20

  def initialize(team_a_score, team_b_score)
    @team_a_score = team_a_score
    @team_b_score = team_b_score
  end

  def game_over?
    return team_a_wins || team_b_wins
  end

  def showable_team_a_score
    current_team_score(@team_a_score, @team_b_score)
  end

  def showable_team_b_score
    current_team_score(@team_b_score, @team_a_score)
  end

  def winner
    return :team_a if team_a_wins
    return :team_b if team_b_wins
    return nil
  end

  private

  def current_team_score(current_team_score, opponent_score)
    return current_team_score if current_team_score < PENULTIMATE_SCORE

    return 'W' if current_team_wins(current_team_score, opponent_score)
    return 'L' if current_team_loses(current_team_score, opponent_score)

    return 'G' if current_team_score == PENULTIMATE_SCORE && opponent_score < PENULTIMATE_SCORE
    return 'D' if current_team_score == opponent_score

    return 'ADV' if current_team_score > opponent_score
    return '-'
  end

  def current_team_wins(current_team_score, opponent_score)
    current_team_score > PENULTIMATE_SCORE && current_team_score - opponent_score >= 2
  end

  def current_team_loses(current_team_score, opponent_score)
    current_team_wins(opponent_score, current_team_score)
  end

  def team_a_wins
    return current_team_wins(@team_a_score, @team_b_score)
  end

  def team_b_wins
    return current_team_wins(@team_b_score, @team_a_score)
  end

end