module RoomsHelper
  def get_team_a_name(player_rankings)
    a_room_players = @room.room_players.select {|room_player| room_player.team == PlayersController::TEAM_A_ID}
    team_a_players = []
    for room_player in a_room_players
      team_a_players << (@room.players.select {|player| player.id == room_player.player_id})[0]
    end

    if team_a_players.length > 0
      names = []
      team_a_players.each do |player|
        if player_rankings.has_key?(player.id)
          names << "#{player.name} (\##{player_rankings[player.id]})"
        else
          names << player.name
        end
      end
      name = names.join(' // ')
    else
      name = "Chatty"
    end
    name
  end

  def team_b_name(player_rankings)
    b_room_players = @room.room_players.select {|room_player| room_player.team == PlayersController::TEAM_B_ID}
    team_b_players = []
    for room_player in b_room_players
      team_b_players << (@room.players.select {|player| player.id == room_player.player_id})[0]
    end

    if team_b_players.length > 0
      names = []
      team_b_players.each do |player|
        if player_rankings.has_key?(player.id)
          names << "#{player.name} (\##{player_rankings[player.id]})"
        else
          names << player.name
        end
      end
      name = names.join(' // ')
    else
      name = "Sassy"
    end

    name
  end

end
