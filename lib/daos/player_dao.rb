class PlayerDao
  LEADERBOARD_DEVIATION_CUTOFF = 2.0

  # @return [Array<Player>]
  def self.get_leaderboard_players(deviation_cutoff, limit = 30)
    unless deviation_cutoff
      deviation_cutoff = LEADERBOARD_DEVIATION_CUTOFF
    end
    Player
        .where('rating_deviation < ?', deviation_cutoff)
        .limit(limit)
        .order(rating_skill: :desc)
  end
end