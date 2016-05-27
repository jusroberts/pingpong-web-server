## -*- encoding : utf-8 -*-
module Saulabs
  module TrueSkill

    class ScoreBasedBayesianRating

      # @return [Array<Array<TrueSkill::Rating>>]
      attr_reader :teams

      # @return [Float]
      attr_reader :beta

      # @return [Float]
      attr_reader :beta_squared

      # @return [Float]
      attr_reader :gamma

      # @return [Float]
      attr_reader :gamma_squared


      # @return [Boolean]
      attr_reader :skills_additive





      # Creates a new skill estimate for given scores and team configuration based on the given game parameters
      # Works for the special case: two teams
      #
      # @param [{ Array<TrueSkill::Rating>, Array<TrueSkill::Rating> }] teams
      #   player-ratings grouped in Arrays by teams
      #
      # @option options [Float] :beta (4.166667)
      #   the length of the skill-chain. Use a low value for games with a small amount of chance (Go, Chess, etc.) and
      #   a high value for games with a high amount of chance (Uno, Bridge, etc.)
      # @option options [Float] :gamma
      #   variance of score distribution. should be extracted from user data. For games with few scoring events (Soccer, etc)
      #   gamma is small, for games with many scoring events (Shooter, etc), gamma is large
      # @param [Float] score
      #   scores obtained by the respective teams s = s1 - s2 (can be negative)
      # @option options [Boolean] :skills_additive (true)
      #   true is valid for games like Halo etc, where skill is additive (2 players are better than 1),
      #   false for card games like Skat, Doppelkopf, Bridge where skills are not additive,
      #         two players dont make the team stronger, skills averaged)
      #
      # @example Calculating new skills of a two team game, where one team has one player and the other two
      #
      #  require 'rubygems'
      #  require 'saulabs/trueskill'
      #
      #  include Saulabs::TrueSkill
      #
      #  # team 1 has just one player with a mean skill of 27.1, a skill-deviation of 2.13
      #  # and a play activity of 100 %
      #  team1 = [Rating.new(27.1, 2.13, 1.0)]
      #
      #  # team 2 has two players
      #  team2 = [Rating.new(22.0, 0.98, 0.8), Rating.new(31.1, 5.33, 0.9)]
      #
      #  # team 1 got 10.0 points and team 2 3.0
      #  graph = FactorGraph.new( team1 => 10.0, team2 => 3.0 )
      #
      #  # update the Ratings
      #  graph.update_skills

    def initialize(score_teams_hash, options = {})
      @teams  = score_teams_hash.keys
      @scores = score_teams_hash.values
      raise "teams.size should be 2: this implementation of the score based bayesian rating only works for two teams" unless @teams.size == 2

      opts = {
            :beta => 25/6.0,
            :skills_additive => true
            }.merge(options)
      @beta = opts[:beta]
      @beta_squared = @beta**2

      @skills_additive = opts[:skills_additive]

      @gamma = options[:gamma] || 0.1
      @gamma_squared = @gamma * @gamma

      @teams = teams

    end

    def update_skills
        #Code should work in general case, but has, however, only been tested for the cased 1vs1,1vs2,1vs3,2vs2
        #for these cases, the analytical solution has been calculated and generalized

        n_1    = @skills_additive ? 1 : @teams[0].size.to_f
        n_2    = @skills_additive ? 1 : @teams[1].size.to_f
        n_max  = [n_1 , n_2].max
        #n_1, n_2 and n_max are set to 1, if skills_additive is true
        #this may look a little bit strange, but is a solution of the analytical equation
        #a pdf with the results will be added
        n      = @teams[0].size.to_f + @teams[1].size.to_f
        n_diff = @skills_additive ? n -2 : (@teams[0].size -  @teams[1].size).abs   #if skills_additive = True, n_diff is set to n - 2
        var_1  = @teams[0].inject(0){|sum,item| sum + item.variance}
        var_2  = @teams[1].inject(0){|sum,item| sum + item.variance}
        mean_1 = @teams[0].inject(0){|sum,item| sum + item.mean}
        mean_2 = @teams[1].inject(0){|sum,item| sum + item.mean}

        @teams[0].map{|rating|
          #calculate rating here:
          precision = 1.0 / rating.variance + n_1**(-2)/ ( @beta_squared * (2 + n_diff) / n_max + @gamma_squared + var_2 / n_2**2 + (var_1 - rating.variance) / n_1**2)
          precision_mean = rating.mean / rating.variance + n_1**(-1) * (@scores[0] - @scores[1] + mean_2 / n_2 - (mean_1 - rating.mean) / n_1) /  ( @beta_squared * (2 + n_diff) / n_max + @gamma_squared + var_2 / n_2**2 + (var_1 - rating.variance) / n_1**2)
          #update ratings:
          partial_updated_precision = rating.precision + rating.activity*( precision - rating.precision)
          partial_updated_precision_mean =  rating.precision_mean + rating.activity * (precision_mean - rating.precision_mean)
          rating.replace(Gauss::Distribution.new(partial_updated_precision_mean / partial_updated_precision, (1.0 / partial_updated_precision + rating.tau_squared)**0.5))
        }
        @teams[1].map{|rating|
          #calculate rating here:
          precision = 1.0 / rating.variance + n_2**(-2)/ ( @beta_squared * (2 + n_diff) / n_max + @gamma_squared + var_1 / n_1**2 + (var_2 - rating.variance) / n_2**2)
          precision_mean = rating.mean / rating.variance + n_2**(-1) * (@scores[1] - @scores[0] + mean_1 / n_1 - (mean_2 - rating.mean) / n_2) /  ( @beta_squared * (2 + n_diff) / n_max + @gamma_squared + var_1 / n_1**2 + (var_2 - rating.variance) / n_2**2)
          #update ratings:
          partial_updated_precision = rating.precision + rating.activity*( precision - rating.precision)
          partial_updated_precision_mean =  rating.precision_mean + rating.activity * (precision_mean - rating.precision_mean)
          rating.replace(Gauss::Distribution.new(partial_updated_precision_mean / partial_updated_precision, (1.0 / partial_updated_precision + rating.tau_squared)**0.5))
        }
      end
    end
  end
end
