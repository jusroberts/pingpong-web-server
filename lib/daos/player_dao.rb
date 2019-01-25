class PlayerDao
  LEADERBOARD_DEVIATION_CUTOFF = 2.0

  # @return [Array<Player>]
  def self.get_leaderboard_players(deviation_cutoff, limit = 30, season_id = nil)
    unless deviation_cutoff
      deviation_cutoff = LEADERBOARD_DEVIATION_CUTOFF
    end
    if season_id == nil
      players = Player
        .where('rating_deviation < ?', deviation_cutoff)
        .where('is_archived = ?', false)
        .limit(limit)
        .order(rating_skill: :desc)
    else
      players = []
      player_ratings = PlayerRating
        .where('season_id = ?', season_id)
        .where('deviation < ?', deviation_cutoff)
        .limit(limit)
        .order(skill: :desc)
      player_ratings.each do |player_rating|
        if !player_rating.player.is_archived
          players << player_rating.player
        end
      end
    end
    players
  end

  def self.get_player(player_id)
    Player.where('id = ?', player_id)
    .limit(1)
  end
end
