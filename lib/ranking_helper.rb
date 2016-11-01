class RankingHelper
  # @param [Array<Integer>]
  # @return [Hash{Integer => Integer}]
  def self.get_player_rankings(player_ids)
    # @type [Hash{Integer => Integer}]
    ranked_players = {}

    rank = 0
    # @type player [Player]
    PlayerDao::get_leaderboard_players(PlayerDao::LEADERBOARD_DEVIATION_CUTOFF).each do |player|
      rank += 1
      if player_ids.include?(player.id)
        ranked_players[player.id] = rank
      end
      if ranked_players.length == player_ids.length
        break
      end
    end
    ranked_players
  end
end