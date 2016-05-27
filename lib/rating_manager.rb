require 'time'
require 'rating/trueskill'
include Saulabs::TrueSkill

class RatingManager
  def initialize
    @beta = 2.0
    @gamma = 0.5
  end

  # @param player [Player]
  # @return [Rating]
  private def get_rating_for_player(player)
    Rating.new(player.rating_skill, player.rating_confidence, 1.0)
  end

  # @param team_1 [Array<Player>]
  # @param team_1_score_differential [Float]
  # @param team_2 [Array<Player>]
  # @param team_2_score_differential [Float]
  # @return [Array<Array<Player>>]
  public def process_game(team_1, team_1_score_differential, team_2, team_2_score_differential)
    # @param team_1_ratings [Array<Rating>]
    team_1_ratings = team_1.map do |player|
      # @type player [Player]
      get_rating_for_player(player)
    end
    # @param team_2_ratings [Array<Rating>]
    team_2_ratings = team_2.map do |player|
      # @type player [Player]
      get_rating_for_player(player)
    end

    # team 1 wins by 10 points against team 2
    graph = ScoreBasedBayesianRating.new(
        {team_1_ratings => team_1_score_differential, team_2_ratings => team_2_score_differential},
        {:beta => @beta, :gamma => @gamma}
    )

    # update the Ratings
    graph.update_skills

    # update the player objects accordingly
    team_1.each_with_index do |player, index|
      # @type player [Player]
      # @type rating [Rating]
      rating = team_1_ratings[index]
      player.rating_skill = rating.mean
      player.rating_confidence = rating.deviation
      player.save
    end

    team_2.each_with_index do |player, index|
      # @type player [Player]
      # @type rating [Rating]
      rating = team_2_ratings[index]
      player.rating_skill = rating.mean
      player.rating_confidence = rating.deviation
      player.save
    end

    [team_1, team_2]
  end
end