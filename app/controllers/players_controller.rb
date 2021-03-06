class PlayersController < ApplicationController
  TEAM_A_ID = 'a'
  TEAM_B_ID = 'b'
  TEAM_IDS = [TEAM_A_ID, TEAM_B_ID]

  before_action :set_player, only: [:new_post, :confirm, :delete, :attach_image, :attach_image_post]
  before_action :set_room_id, except: [:list_all_players, :change_player_pin, :change_player_pin_post]

  def handle_player_hash
    # @type [String]
    hash = params[:uidHash]
    # SHA256 should be 32 bytes, 64 hex characters
    raise("invalid hash") if hash.length != 64

    # Lookup or create a player record for this player
    player = Player.find_by rfid_hash: hash
    if player.nil?
      # If a player with this hash doesn't exist, create a new one
      player = Player.create(rfid_hash: hash)
      # Send a message to the client to redirect to the create page
      ::WebsocketRails[:"room#{@id}"].trigger 'user_scan_new', player.id
    else
      # Otherwise this player exists, so add them to this room's current players
      add_player_and_update_room(player)
    end

    render nothing: true
  end

  def new
    @name = ''
    if params[:player_id].nil?
      # Grab the latest player added that doesn't have a name, we'll edit them
      @player = Player.where(name: nil).last
      raise("No unregistered players found") if @player.nil?
    else
      # If we're adding/editing a specific player
      @player = Player.find_by id: params[:player_id]
      raise("Failed to find player for id #{params[:player_id]}") if @player.nil?
      @name = @player.name
    end

    add_new_player(@id, @player)
  end

  def new_cancel
    player = Player.where(name: nil).last
    remove_player_from_room_if_present(player)
    if player
      player.delete
    end
    redirect_to room_game_newfull_path
  end

  def new_post
    raise("Failed to find player for id #{params[:player_id]}") if @player.nil?
    @player.name = params[:name]
    if params[:pin]
      @player.pin = params[:pin]
    end
    @player.save
    redirect_to room_game_player_attach_image_path(room_id: @id, player_id: @player.id)
  end

  def attach_image
  end

  def attach_image_post
    unless params[:capture].nil?
      image = params[:capture][:image]
      hash = Cloudinary::Uploader.upload(image, cloudinary_auth)
      image_url = hash['secure_url']
      @player.update_attribute(:image_url, image_url)
    end
    redirect_to room_game_newfull_path
  end

  def confirm
  end

  def delete
  end

  def get_rank
    # @type [Array<Integer>]
    player_ids = params[:playerIds]
    unless player_ids
      render :json => nil
      return
    end
    player_ids.map! { |player_id| player_id.to_i }

    render :json => RankingHelper::get_player_rankings(player_ids)
  end

  def predict_game
    player_ids = params[:playerIdHash]
    room_id = params[:room_id]

    team_a = player_ids[:a].map { |player_id| Player.find(player_id).get_latest_rating(room_id) }
    team_b = player_ids[:b].map { |player_id| Player.find(player_id).get_latest_rating(room_id) }

    manager = ResultPredictionManager.new
    winning_team, winning_score = manager.predict_result(team_a, team_b)

    if winning_team == team_a
      favored_team = :a
    elsif winning_team == team_b
      favored_team = :b
    else
      raise "Failed to predict game, invalid winning team #{winning_team}"
    end

    # winning_ids = winning_team.map { |player| player.id }

    render :json => {
        favoredTeam: favored_team,
        pointSpread: winning_score
    }
  end

  def optimize_teams
    player_ids = params[:players].split(',')
    room_id = params[:room_id]
    season = Room.find(room_id).get_active_season
    player_ratings = player_ids.map { |player_id| Player.find(player_id).get_latest_rating(room_id) }

    manager = ResultPredictionManager.new
    team_1, team_2 = manager.optimize_teams(*player_ratings)

    # Client-side will clear all existing players, so add them back on the server side
    # and fire off websocket updates

    team_1.each do |player_rating|
      add_player_and_update_room(player_rating.player)
    end
    team_2.each do |player_rating|
      add_player_and_update_room(player_rating.player)
    end

    playerIdHash = {
        a: team_1.map { |player_rating| player_rating.player.id },
        b: team_2.map { |player_rating| player_rating.player.id },
    }

    render :json => playerIdHash
  end

  def lookup_player
    @players = Player.where.not(name: nil).sort_by(&:name)

    # If we got here from the "already in the system?" link after scanning an
    # unrecognized badge, we want to pass the new-badge player through the process
    # so that we can update the chosen player's badge hash from the new-badge 
    # "empty" player entry, and then delete that "empty" entry.
    if params[:badged_player_id]
      @badged_player_id = params[:badged_player_id]
    end
  end

  def login_as_player
    player_id = params[:player_id]
    @player = Player.find(player_id)
    raise "No player found for id '#{player_id}'" unless @player

    # If we got here from the "already in the system?" link after scanning an
    # unrecognized badge, we want to pass the new-badge player through the process
    # so that we can update the chosen player's badge hash from the new-badge 
    # "empty" player entry, and then delete that "empty" entry.
    if params[:badged_player_id]
      @badged_player_id = params[:badged_player_id]
    end

    # If an error was passed to this page, show that error.
    if params[:error]
      @error = params[:error]
    end
  end
  def login_as_player_post
    player_id = params[:player_id]
    @player = Player.find(player_id)
    raise "No player found for id '#{player_id}'" unless @player

    pin = params[:pin]
    if pin && pin.strip == @player.pin
      add_player_and_update_room(@player)

      # If we got here from the "already in the system?" link after scanning an
      # unrecognized badge, we want to take the new badge's hash from the 
      # "empty" player entry that badged in, and apply it to the player that was
      # just selected (allowing players to update their badge), then delete 
      # "empty" player entry since it doesn't mean anything anymore.
      if params[:badged_player_id]
        update_player_badge(@player, params[:badged_player_id])
      end

      redirect_to room_game_newfull_path
    else
      redirect_to room_game_login_as_player_path(
        id: @id, 
        player_id: @player.id, 
        error: "Incorrect pin!", 
        badged_player_id: params[:badged_player_id]
      )
    end
  end

  def change_player_pin
    player_id = params[:player_id]
    @player = Player.find(player_id)
    raise "No player found for id '#{player_id}'" unless @player

    if params[:error]
      @error = params[:error]
    end
  end
  def change_player_pin_post
    player_id = params[:player_id]
    @player = Player.find(player_id)
    raise "No player found for id '#{player_id}'" unless @player

    new_pin = params[:new_pin]
    current_pin = params[:current_pin]
    if @player.pin != current_pin
      redirect_to change_player_pin_path(
        player_id: @player.id,
        error: "Incorrect pin!"
      )
    elsif !new_pin || new_pin.size < 3
      redirect_to change_player_pin_path(
        player_id: @player.id,
        error: "Invalid pin; your pin must be at least 3 digits long."
      )
    else
      @player.pin = new_pin
      @player.save
      redirect_to player_report_path(player_id: @player.id)
    end
  end

  # Used by the ajax player search
  def list_all_players
    json_output = Player.all.map do |player|
      {
        id: player.id,
        name: player.name,
        image_url: player.image_url,
      }
    end

    render :json => json_output
  end
  

  private

  # @param player [Player]
  def add_player_and_update_room(player)
    room_player = add_new_player(@id, player)
    ::WebsocketRails[:"room#{@id}"].trigger 'user_scan_existing', {
        :player_id => player.id,
        :image_url => player.image_url,
        :team => room_player.team,
        :player_number => room_player.player_number
    }
  end

  def add_new_player(room_id, player)
    # Pull the room object
    # @type [Room]
    room = Room.find_by id: room_id
    raise("Invalid room id #{room_id}") if room.nil?

    team_size = (room.player_count / 2).to_i
    # Grab the players for this room to find where to put this player
    room_players = room.room_players

    # If this player is already playing, we're done here
    self_players = room_players.select {|room_player| room_player.player_id == player.id}
    if self_players.length > 0
      return RoomPlayer.find_by player_id: player.id, room_id: room_id
    end

    # @type [Array<RoomPlayer>]
    team_a_players = room_players.select {|room_player| room_player.team == TEAM_A_ID}
    # @type [Array<RoomPlayer>]
    team_b_players = room_players.select {|room_player| room_player.team == TEAM_B_ID}

    # Add to team A first
    if team_a_players.length < team_size
      room_player = RoomPlayer.new(room_id: room_id, player_id: player.id, team: TEAM_A_ID, player_number: team_a_players.length + 1)
    elsif team_b_players.length < team_size
      # If team B isn't full, add to it
      room_player = RoomPlayer.new(room_id: room_id, player_id: player.id, team: TEAM_B_ID, player_number: team_b_players.length + 1)
    else
      # Failing that, add to the last player slot
      room_player = RoomPlayer.find_by room_id: room_id, team: TEAM_B_ID, player_number: team_size
      raise("Failed to find player number #{team_size} for team #{TEAM_B_ID} and room #{room_id} when trying to overwrite last player") if room_player.nil?
      room_player.player_id = player.id
    end

    room_player.save
    room_player
  end

  def set_player
    @player = Player.find(params[:player_id])
  end

  def set_room_id
    @id = Room.find(params[:room_id]).id
  end

  def update_player_badge(player_to_update, badged_player_id)
    badged_player = Player.find(badged_player_id)
    raise "Badged-in player not found for id '#{badged_player_id}'" unless badged_player

    player_to_update.rfid_hash = badged_player.rfid_hash
    remove_player_from_room_if_present(badged_player)
    badged_player.delete
    player_to_update.save
  end

  def remove_player_from_room_if_present(player)
    room_player = RoomPlayer.find_by room_id: @id, player_id: player.id
    room_player.delete if room_player
  end

  def cloudinary_auth
    {
      cloud_name: ENV["CLOUDINARY_NAME"],
      api_key:    ENV["CLOUDINARY_API_KEY"],
      api_secret: ENV["CLOUDINARY_API_SECRET"]
    }
  end

end
