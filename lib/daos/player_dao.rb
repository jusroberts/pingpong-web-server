class PlayerDao
  LEADERBOARD_DEVIATION_CUTOFF = 3.0

  # @return [Array<Player>]
  def self.get_leaderboard_players
    Player
        .where('rating_deviation < ?', LEADERBOARD_DEVIATION_CUTOFF)
        .limit(30)
        .order(rating_skill: :desc)
  end
end