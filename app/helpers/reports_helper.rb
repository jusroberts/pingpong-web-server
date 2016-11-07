module ReportsHelper
  def player_name player_id
    if !cached_names[player_id]
      cached_names[player_id] = Player.find(player_id).name rescue "ERROR"
    end
    name = cached_names[player_id]
    link_to(name, player_report_path(player_id))
  end

  def cached_names
    @cached_names ||= {}
  end

  # @param player_id [Integer]
  # @param records [Hash{Integer => Array<GameHistory>}]
  def team_names(player_id, records)
    # @type player_record [GameHistory]
    player_record = records.select { |record| record.player_id == player_id }.first
    win_or_lose = player_record.win

    player_team_records = records.select { |record| record.win == win_or_lose }
    opponent_team_records = records.select { |record| record.win != win_or_lose }

    player_team_names = player_team_records.map { |record| record.player_id }.sort.map { |player_id| player_name(player_id) }
    opponent_team_names = opponent_team_records.map { |record| record.player_id }.sort.map { |player_id| player_name(player_id) }

    [player_record, player_team_names.join(' and '), opponent_team_names.join(' and ')]
  end
end
