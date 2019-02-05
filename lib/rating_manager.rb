require 'time'
require 'rating/trueskill'
include Saulabs::TrueSkill

# http://www.moserware.com/2010/03/computing-your-skill.html
class RatingManager
  # Default initial mean of ratings.
  TRUESKILL_MU = 25.0
  # Default initial standard deviation of ratings.
  TRUESKILL_SIGMA = 8.333333333333334
  # Default distance 4.166666 guarantees about 76% chance of winning.
  # Small element of chance in ping pong, so go lower
  TRUESKILL_BETA = 2.0
  # Default dynamic factor.
  TRUESKILL_TAU = 0.08333333333333334
  # Variance of score distribution. should be extracted from user data. For games with few scoring events (Soccer, etc)
  #   gamma is small, for games with many scoring events (Shooter, etc), gamma is large
  #   Defaults to 0.1
  TRUESKILL_GAMMA = 4.0
  # Default draw probability of the game.
  TRUESKILL_DRAW_PROBABILITY = 0.0

  def initialize
    @beta = TRUESKILL_BETA
    @gamma = TRUESKILL_GAMMA
  end

  # @param player_rating [PlayerRating]
  # @return [Rating]
  private def get_rating_for_player(player_rating)
    skill = player_rating.skill ? player_rating.skill : TRUESKILL_MU
    deviation = player_rating.deviation ? player_rating.deviation : TRUESKILL_SIGMA
    Rating.new(skill, deviation, 1.0)
  end

  # @param team_1 [Array<PlayerRating>]
  # @param team_1_score_differential [Float]
  # @param team_2 [Array<PlayerRating>]
  # @param team_2_score_differential [Float]
  # @return [Array<Array<Player>>]
  public def process_game(team_1, team_1_score_differential, team_2, team_2_score_differential)
    # @param team_1_ratings [Array<Rating>]
    team_1_ratings = team_1.map do |player|
      # @type player_rating [PlayerRating]
      get_rating_for_player(player)
    end
    # @param team_2_ratings [Array<Rating>]
    team_2_ratings = team_2.map do |player|
      # @type player_rating [PlayerRating]
      get_rating_for_player(player)
    end

    # team 1 wins by 10 points against team 2
    graph = ScoreBasedBayesianRating.new(
        {team_1_ratings => team_1_score_differential, team_2_ratings => team_2_score_differential},
        {:beta => @beta, :gamma => @gamma, :skills_additive => false}
    )

    # update the Ratings
    graph.update_skills

    # update the player objects accordingly
    team_1.each_with_index do |player_rating, index|
      # @type player_rating [PlayerRating]
      # @type rating [Rating]
      rating = team_1_ratings[index]
      player_rating.skill = rating.mean
      player_rating.deviation = rating.deviation
    end

    team_2.each_with_index do |player_rating, index|
      # @type player_rating [PlayerRating]
      # @type rating [Rating]
      rating = team_2_ratings[index]
      player_rating.skill = rating.mean
      player_rating.deviation = rating.deviation
    end

    [team_1, team_2]
  end
end
