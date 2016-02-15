class GameLogic

  def initialize(team_a_score, team_b_score)
    @team_a_score = team_a_score
    @team_b_score = team_b_score
  end

  def game_over?
    return team_a_wins || team_b_wins
  end

  private

  def team_a_wins
    return @team_a_score > 20 && @team_a_score - @team_b_score >= 2
  end

  def team_b_wins
    return @team_b_score > 20 && @team_b_score - @team_a_score >= 2
  end

end