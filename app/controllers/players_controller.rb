class PlayersController < ApplicationController
  TEAM_SIZE = 1
  TEAM_A_ID = 'a'
  TEAM_B_ID = 'b'
  TEAM_IDS = [TEAM_A_ID, TEAM_B_ID]

  before_action :set_player, only: [:new_post, :confirm, :delete, :attach_image, :attach_image_post]
  before_action :set_room_id

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
      add_new_player(@id, player)
      ::WebsocketRails[:"room#{@id}"].trigger 'user_scan_existing', player.id
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

  def new_post
    raise("Failed to find player for id #{params[:player_id]}") if @player.nil?
    @player.name = params[:name]
    @player.save
    redirect_to room_game_player_attach_image_path(room_id: @id, player_id: @player.id)
  end

  def attach_image
  end

  def attach_image_post
    unless params[:capture].nil?
      image = params[:capture][:image]
      hash = Cloudinary::Uploader.upload(image)
      image_url = hash['secure_url']
      @player.update_attribute(:image_url, image_url)
    end
    redirect_to room_game_new_path
  end

  def confirm
  end

  def delete
    #Player.find(params[:player_id]).delete
  end

  private

  def add_new_player(room_id, player)
    # Pull the room object
    room = Room.find_by id: room_id
    raise("Invalid room id #{room_id}") if room.nil?

    # Grab the players for this room to find where to put this player
    room_players = room.room_players

    # If this player is already playing, we're done here
    self_players = room_players.select {|room_player| room_player.player_id == player.id}
    if self_players.length > 0
      return
    end

    team_a_players = room_players.select {|room_player| room_player.team == TEAM_A_ID}
    team_b_players = room_players.select {|room_player| room_player.team == TEAM_B_ID}

    # Add to team A first
    if team_a_players.length < TEAM_SIZE
      room_player = RoomPlayer.new(room_id: room_id, player_id: player.id, team: TEAM_A_ID, player_number: team_a_players.length + 1)
    elsif team_b_players.length < TEAM_SIZE
      # If team B isn't full, add to it
      room_player = RoomPlayer.new(room_id: room_id, player_id: player.id, team: TEAM_B_ID, player_number: team_a_players.length + 1)
    else
      # Failing that, add to the last player slot
      room_player = RoomPlayer.find_by room_id: room_id, team: TEAM_B_ID, player_number: (TEAM_SIZE * 2)
      raise("Failed to find player number #{TEAM_SIZE} for team #{TEAM_B_ID} and room #{room_id} when trying to overwrite last player") if room_player.nil?
      room_player.player_id = player.id
    end

    room_player.save
  end

  def set_player
    @player = Player.find(params[:player_id])
  end

  def set_room_id
    @id = Room.find(params[:room_id]).id
  end

end
