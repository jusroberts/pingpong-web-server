class GameHistoryDao

  # @param player_ids [Array<Integer>]
  # @return [Hash{Integer => Array<GameHistory>}]
  def self.get_per_game_histories(*player_ids)
    game_ids = GameHistory
                   .select('game_id, count(*) as hits')
                   .where(:player_id => player_ids)
                   .group('game_id')
                   .having('count(*) >= ?', player_ids.length)
                   .pluck(:game_id)

    histories = GameHistory
		    .where(:game_id => game_ids)
		    .order(id: :desc)

    # @type game_history [GameHistory]
    histories.group_by do |game_history|
      game_history.game_id
    end
  end
end