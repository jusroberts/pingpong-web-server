module RoomsHelper
  def team_a_name
    a_room_players = @room.room_players.select {|room_player| room_player.team == PlayersController::TEAM_A_ID}
    team_a_players = []
    for room_player in a_room_players
      team_a_players << (@room.players.select {|player| player.id == room_player.player_id})[0]
    end

    if team_a_players.length > 0
      name = team_a_players.map { |p| p.name }.join(' // ')
    else
      name = "Chatty"
    end
    return(name)
  end

  def team_b_name
    b_room_players = @room.room_players.select {|room_player| room_player.team == PlayersController::TEAM_B_ID}
    team_b_players = []
    for room_player in b_room_players
      team_b_players << (@room.players.select {|player| player.id == room_player.player_id})[0]
    end

    if team_b_players.length > 0
      name = team_b_players.map { |p| p.name }.join(' // ')
    else
      name = "Sassy"
    end

    return(name)
  end

end
