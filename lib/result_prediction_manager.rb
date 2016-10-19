class ResultPredictionManager

  # @param team_1 [Array<Player>]
  # @param team_2 [Array<Player>]
  # @return [Array<Array<Player>, Number>]
  def predict_result(team_1, team_2)
    team_1_winning_lowest_rating_diff, team_1_winning_score = get_lowest_rating_change(team_1, team_2)
    team_2_winning_lowest_rating_diff, team_2_winning_score = get_lowest_rating_change(team_2, team_1)

    if (team_1_winning_lowest_rating_diff < team_2_winning_lowest_rating_diff)
      [team_1, team_1_winning_score]
    else
      [team_2, team_2_winning_score]
    end
  end

  private

  # @param winning_team [Array<Player>]
  # @param losing_team [Array<Player>]
  # @return [Array<Number>]
  def get_lowest_rating_change(winning_team, losing_team)
    running_score = 0
    lowest_difference = 100

    while running_score < 20
      result = get_average_rating_change(winning_team, losing_team, running_score)
      # Keep going as long as the results get smaller, once they start going up we're done
      if result < lowest_difference
        lowest_difference = result
      else
        return [lowest_difference, running_score - 1]
      end
      running_score += 1
    end
    [100, 20]
  end

  # @param winning_team [Array<Player>]
  # @param losing_team [Array<Player>]
  # @return [Array<Number>]
  def get_average_rating_change(winning_team, losing_team, score)
    winning_team_clone = clone_team(winning_team)
    winning_team_start_rating = get_average_rating(winning_team)
    losing_team_clone = clone_team(losing_team)
    losing_team_start_rating = get_average_rating(losing_team)

    manager = RatingManager.new
    manager.process_game(winning_team_clone, score, losing_team_clone, -score)

    winning_team_end_rating = get_average_rating(winning_team_clone)
    losing_team_end_rating = get_average_rating(losing_team_clone)

    ((winning_team_start_rating - winning_team_end_rating).abs + (losing_team_start_rating - losing_team_end_rating).abs) / 2
  end

  # @param team [Array<Player>]
  # @return [Number]
  def get_average_rating(team)
    total_skill = team.inject(0) { |carry, player| carry + player.rating_skill }
    total_skill / team.length
  end

  # @param team [Array<Player>]
  # @return [Array<Player>]
  def clone_team(team)
    team.map { |player| player.dup }
  end
end