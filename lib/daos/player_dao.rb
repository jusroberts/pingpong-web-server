class PlayerDao
  LEADERBOARD_DEVIATION_CUTOFF = 2.0

  # @return [Array<Player>]
  def self.get_leaderboard_players(deviation_cutoff, limit = 30)
    unless deviation_cutoff
      deviation_cutoff = LEADERBOARD_DEVIATION_CUTOFF
    end
    return Player
      .where('rating_deviation < ?', deviation_cutoff)
      .where('is_archived = ?', false)
      .limit(limit)
      .order(rating_skill: :desc)
  end

  # @return [Array<PlayerRating>]
  def self.get_leaderboard_player_ratings(season_id, game_type, deviation_cutoff, limit = 30)
    unless deviation_cutoff
      deviation_cutoff = LEADERBOARD_DEVIATION_CUTOFF
    end
    return_player_ratings = []
    player_ratings = PlayerRating
      .where('season_id = ?', season_id)
      .where('game_type = ?', game_type)
      .where('deviation < ?', deviation_cutoff)
      .limit(limit)
      .order(skill: :desc)
    player_ratings.each do |player_rating|
      if !player_rating.player.is_archived
        return_player_ratings << player_rating
      end
    end
    return_player_ratings
  end
end
