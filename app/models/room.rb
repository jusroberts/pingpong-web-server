class Room < ActiveRecord::Base
  has_many :room_players, dependent: :destroy
  has_many :players, through: :room_players
  has_many :seasons, dependent: :destroy

  NO_TEAM_SERVING = 0
  TEAM_A_SERVING = 1
  TEAM_B_SERVING = 2

  # @param quit [boolean]
  def end_game(quit, room)
    if memorable_game?
      save_history(room)
    end

    update_attributes(team_a_score: 0, team_b_score: 0, game: false)
    if quit
      room_players.delete_all
      update_attribute(:game_session_id, nil)
    else
      update_attributes(team_a_score: 0, team_b_score: 0, game: true)
      room_players.each do |room_player|
        if room_player.team == "a"
          room_player.update_attribute(:team, "b")
        elsif room_player.team == "b"
          room_player.update_attribute(:team, "a")
        end
      end

    end
  end

  def memorable_game?
    room_players.length > 0 &&
    # Should be an even number of players
        room_players.length % 2 === 0 &&
        room_players.length == player_count &&
    # Somebody should have won the game
        (team_a_score > GameLogic::PENULTIMATE_SCORE || team_b_score > GameLogic::PENULTIMATE_SCORE) &&
        !game_session_id.nil?
  end

  def save_history(room)
    # @type [Array<RoomPlayer>]
    team_a_players = room_players.select {|room_player| room_player.team == PlayersController::TEAM_A_ID}
    # @type [Array<RoomPlayer>]
    team_b_players = room_players.select {|room_player| room_player.team == PlayersController::TEAM_B_ID}

    # We should batch this but ActiveRecord makes it a pain in the ass and I don't care that much
    # @type [Hash{Integer => GameHistory}]
    histories = {}
    # @type [Array<Player>]
    winning_players = []
    # @type [Array<Player>]
    losing_players = []
    if team_a_score > team_b_score
      # Yay for team A
      team_a_players.each do |room_player|
        history = new_game_history(room, room_player, true)
        histories[room_player.player_id] = history
        winning_players << Player.find_by(:id => room_player.player_id)
      end
      team_b_players.each do |room_player|
        history = new_game_history(room, room_player, false)
        histories[room_player.player_id] = history
        losing_players << Player.find_by(:id => room_player.player_id)
      end
    else
      team_a_players.each do |room_player|
        history = new_game_history(room, room_player, false)
        histories[room_player.player_id] = history
        losing_players << Player.find_by(:id => room_player.player_id)
      end
      # All glory to team B
      team_b_players.each do |room_player|
        history = new_game_history(room, room_player, true)
        histories[room_player.player_id] = history
        winning_players << Player.find_by(:id => room_player.player_id)
      end
    end

    # Use the first player's history PK as the game ID because it's an easy way to generate a unique, sequential integer
    game_id = histories.values[0].id
    histories.each do |player_id, history|
      history.update_attributes(game_id: game_id)
    end

    starting_skills = {}
    starting_deviations = {}

    # Store starting ratings so we can calculate differential
    players = winning_players + losing_players
    players.each do |player|
      starting_skills[player.id] = player.rating_skill
      starting_deviations[player.id] = player.rating_deviation
    end

    # Update skills
    margin = (team_a_score - team_b_score).abs
    manager = RatingManager.new
    manager.process_game(winning_players, margin, losing_players, -margin)
    winning_players.each { |player| player.save }
    losing_players.each { |player| player.save }

    # Calculate and store rating differentials
    # @type player [Player]
    players.each do |player|
      # @type [GameHistory]
      player_history = histories[player.id]
      player_history.skill_change = player.rating_skill - starting_skills[player.id]
      player_history.deviation_change = player.rating_deviation - starting_deviations[player.id]
      player_history.save
      active_season_id = room.get_active_season.id
      player_rating = player.player_ratings.where(:season_id => active_season_id).first
      if player_rating == nil
        player_rating = PlayerRating.new(
          player_id: player.id,
          season_id: active_season_id
        )
      end
      player_rating.skill = player.rating_skill
      player_rating.deviation = player.rating_deviation
      player_rating.save
    end
  end

  # @param room_player [RoomPlayer]
  # @param win [boolean]
  # @return [GameHistory]
  def new_game_history(room, room_player, win)
    game_history = GameHistory.new(
        room_id: room.id,
        player_id: room_player.player_id,
        game_session_id: room.game_session_id,
        player_count: room.player_count,
        win: win,
        duration_seconds: (room.end_time - room.start_time).to_i
    )
    if room_player.team == PlayersController::TEAM_A_ID
      game_history.player_team_score = room.team_a_score
      game_history.opponent_team_score = room.team_b_score
    else
      game_history.player_team_score = room.team_b_score
      game_history.opponent_team_score = room.team_a_score
    end
    game_history.save
    game_history
  end

  def handle_request_id (request_id)
    if request_id == 0 || last_request_id == nil
      #Request Id has been reset to 0. Likely the client has power cycled
        update_attribute(:last_request_id, 0)
        return true
    end

    if request_id > last_request_id
      update_attribute(:last_request_id, request_id)
      return true
    end
    return false
  end

  # @param increment_or_decrement boolean
  # @param team String
  def update_streak(increment_or_decrement, team)
    if increment_or_decrement
      new_streak = StreakHelper.new().update_streak_increment(team, get_streak_history)
    else
      new_streak = StreakHelper.new().update_streak_decrement(team, get_streak_history)
    end
    update_attribute(:streak, StreakHelper.new().get_new_streak(new_streak))
    update_attribute(:streak_history, new_streak.join(","))
  end

  #@return [int]
  def get_streak_history
    if streak_history == nil
      return []
    else
      return streak_history.split(",").map(&:to_i)
    end
  end

  def get_active_season
    return seasons.where(:active => true).first
  end
end
