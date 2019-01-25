class PlayerDao
  LEADERBOARD_DEVIATION_CUTOFF = 2.0

  # @return [Array<Player>]
  def self.get_leaderboard_players(deviation_cutoff, limit = 30)
    unless deviation_cutoff
      deviation_cutoff = LEADERBOARD_DEVIATION_CUTOFF
    end
    Player
        .where('rating_deviation < ?', deviation_cutoff)
        .where('is_archived = ?', false)
        .limit(limit)
        .order(rating_skill: :desc)
  end

  def self.get_player(player_id)
    Player.where('id = ?', player_id)
    .limit(1)
  end
end