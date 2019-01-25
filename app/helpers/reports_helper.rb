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

  # @param player_id [Integer]
  # @param records [Hash{Integer => Array<GameHistory>}]
  def did_player_win(player_id, records)
    player_record = records.select { |record| record.player_id == player_id }.first
    player_record.win
  end

  def team_a_score
    @team_a_score = 0
  end

  def team_b_score
    @team_b_score = 0
  end

  def increment_score(team)
    if @team_a_score == nil
      team_a_score
    end
    if @team_b_score == nil
      team_b_score
    end

    if team == "a"
      @team_a_score = @team_a_score+1
    else
      @team_b_score = @team_b_score+1
    end
  end

  def get_score(team)
    if team == "a"
      @team_a_score
    else
      @team_b_score
    end
  end

  def get_game_link game_id
    link_to(game_id, game_report_path(game_id))
  end
end
