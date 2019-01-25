class ScoreHistoryDao

  # @param game_id [integer]
  # @return [Array<ScoreHistory>]
  def self.get_score_history(game_id)
    ScoreHistory
        .where('game_id = ?', game_id)
        .order(id: :asc)
  end
end