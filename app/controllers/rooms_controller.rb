require 'time'

class RoomsController < ApplicationController
  before_action :set_room, except: [:index, :new, :create, :home]

  VALID_PLAYER_COUNTS = [2, 4]

  # GET /rooms
  # GET /rooms.json
  def index
    @rooms = Room.all
  end

  # GET /rooms/1
  # GET /rooms/1.json
  def show
    set_current_game_status
  end

  # GET /rooms/new
  def new
    @room = Room.new
  end

  # GET /rooms/1/edit
  def edit
  end

  # POST /rooms
  # POST /rooms.json
  def create
    @room = Room.new(room_params.merge(team_a_score: 0, team_b_score: 0))

    respond_to do |format|
      if @room.save
        format.html { redirect_to @room, notice: 'Room was successfully created.' }
        format.json { render :show, status: :created, location: @room }
      else
        format.html { render :new }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rooms/1
  # PATCH/PUT /rooms/1.json
  def update
    respond_to do |format|
      if @room.update(room_params)
        format.html { redirect_to @room, notice: 'Room was successfully updated.' }
        format.json { render :show, status: :ok, location: @room }
      else
        format.html { render :edit }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rooms/1
  # DELETE /rooms/1.json
  def destroy
    @room.destroy
    respond_to do |format|
      format.html { redirect_to rooms_url, notice: 'Room was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # /api/rooms/1/team/a/increment
  def increment_score
    if should_reset?
      private_game_end_post
      ::WebsocketRails[:"room#{@room.id}"].trigger "new_game_refresh"
      return
    end

    team = params[:team].downcase

    # Times when this call shouldn't happen
    if @room.increment_at && @room.increment_at > 1.seconds.ago
      return
    end
    raise("invalid team") if params[:team].downcase != 'a' && params[:team].downcase != 'b'

    if @room.game
      if should_reset?
        @room.update_attributes(team_a_score: 0, team_b_score: 0)
      else
        current_score = @room.method("team_#{team}_score".to_sym).call()
        @room.update_attribute("team_#{team}_score", current_score + 1)
      end
      set_room
      if GameLogic.new(@room.team_a_score, @room.team_b_score).game_over?
        @room.update_attribute(:game, false)
      end
    end
    send_scores
    @room.update_attribute(:increment_at, Time.now)
    render nothing: true
  end

# /api/rooms/1/send_current_scores
  def send_current_scores
    send_scores
    render text: 'OK'
  end

  # /api/rooms/1/status
  def room_status
    # Standard response
    out = {
        :team_a_score => @room.team_a_score,
        :team_b_score => @room.team_b_score,
        :name => @room.name,
        :has_active_game => @room.game
    }

    # Pull player names
    # @type [Array<Number>]
    team_a_ids = []
    # @type [Array<Number>]
    team_b_ids = []
    player_data = {
        :team_a => [],
        :team_b => []
    }
    @room.room_players.each do |rp|
      if rp.team == PlayersController::TEAM_A_ID
        team_a_ids << rp.player_id
      else
        team_b_ids << rp.player_id
      end
    end

    unless team_a_ids.empty? or team_b_ids.empty?
      # @type [Array<Player>]
      players = Player.where(:id => team_a_ids + team_b_ids)

      players.each do |player|
        if team_a_ids.include? player.id
          player_data[:team_a] << player.name
        elsif team_b_ids.include? player.id
          player_data[:team_b] << player.name
        end
      end
      out[:player_data] = player_data
    end

    # Pull game count
    query = "
      select count(distinct game_id) as count
      from game_histories
      where room_id = #{@room.id} and game_session_id = '#{@room.game_session_id}'"
    count = ActiveRecord::Base.connection.execute(query)

    if !count.nil? and count[0].key?('count')
      # Current game is historical games + 1
      out[:game_count] = count[0]['count'].to_i + 1
    end

    render :json => out
  end

  def game_new
    @id = params[:id] || params[:room_id]
    @game_type = params[:game_type]
    @p1 = params[:p1]
    @p2 = params[:p2]
    @p3 = params[:p3]
    @p4 = params[:p4]
  end

  # Change to singles or doubles mode
  def game_player_count_post
    # Validate that we have a player count and it's sane
    raise("Invalid player count") if (params[:player_count].nil? ||
        !(Integer(params[:player_count]) rescue false) ||
        !VALID_PLAYER_COUNTS.include?(params[:player_count].to_i))

    count = params[:player_count].to_i
    @room.player_count = count
    @room.save
    # Delete players that no longer fit in this game
    RoomPlayer.all.where('room_id = ? AND player_number > ?', @room.id, (count / 2).to_i).delete_all
    render :json => {
        :player_count => count
    }
  end

  def players_clear_post
    # Wipe all the players for this room
    @room.room_players.delete_all
    render text: 'OK'
  end

  def game_newfull
    @id = params[:id] || params[:room_id]
    @player_count = @room.player_count
    ## Load player image URLs
    # Team A.1
    @player_a_1_url = nil
    # Team A.2
    @player_a_2_url = nil
    # Team B.1
    @player_b_1_url = nil
    # Team B.2
    @player_b_2_url = nil

    room_players_by_id = @room.room_players.to_a.index_by {|rp| "#{rp.team}_#{rp.player_number}"}
    @player_ids = {
        :a => [],
        :b => []
    }

    if @player_count == 2
      # Singles
      load_indexed_player_image_url(room_players_by_id, :a, 1, @player_ids)
      load_indexed_player_image_url(room_players_by_id, :b, 1, @player_ids)

    elsif @player_count == 4
      # Doubles
      load_indexed_player_image_url(room_players_by_id, :a, 1, @player_ids)
      load_indexed_player_image_url(room_players_by_id, :a, 2, @player_ids)
      load_indexed_player_image_url(room_players_by_id, :b, 1, @player_ids)
      load_indexed_player_image_url(room_players_by_id, :b, 2, @player_ids)

    else
      # Wat
      raise("Invalid player count #{@player_count}")
    end

    @player_a_1_url ||= "/images/pong_assets/pong_avatar 1 doubles.png"
    @player_a_2_url ||= "/images/pong_assets/pong_avatar 1 doubles.png"
    @player_b_1_url ||= "/images/pong_assets/pong_avatar 2 doubles.png"
    @player_b_2_url ||= "/images/pong_assets/pong_avatar 2 doubles.png"
    # @player_ids = JSON.encode(@player_ids)
    @player_ids = @player_ids.to_json
  end

  def game_new_post

    @room.update_attributes(team_a_score: 0, team_b_score: 0, game: true)

    redirect_to :room_game_play

    # Generate a new game session id
    @room.update_attributes(game_session_id: SecureRandom.base64(16))
  end

  def game_end_post

    private_game_end_post
    if params[:quit].present?
      redirect_to :room_game_interstitial
    else
      redirect_to :room_game_play
    end

  end

  def game_view
    set_current_game_status
  end

  def game_play
    set_current_game_status
  end

  def interstitial
    @id = @room.id
  end

  def home
    @room = Room.all.first rescue nil
    if @room
      set_current_game_status
      render :game_view
    else
      redirect_to :rooms
    end
  end

  def controller
  end

  private

    # @param room_players_by_id [Hash{Number => RoomPlayers}]
    # @param team [String]
    # @param player_number [Number]
    # @param player_ids [Hash{String => Array<Number>}]
    def load_indexed_player_image_url(room_players_by_id, team, player_number, player_ids)
      key = "#{team}_#{player_number}"
      if room_players_by_id.has_key?(key)
        # @type [Player]
        player = Player.find_by id: room_players_by_id[key].player_id
        player_ids[team] << player.id
        instance_variable_set("@player_#{key}_url", player.image_url)
      end
    end

    def set_current_game_status
      game_logic = GameLogic.new(@room.team_a_score, @room.team_b_score)
      @team_a_score = game_logic.showable_team_a_score
      @team_b_score = game_logic.showable_team_b_score

      @team_b_status = @team_b_score == "W" ? "WINNER!" : "&nbsp;".html_safe
      @team_a_status = @team_a_score == "W" ? "WINNER!" : "&nbsp;".html_safe
    end

    def send_scores
      set_room
      game_logic = GameLogic.new(@room.team_a_score, @room.team_b_score)
      ::WebsocketRails[:"room#{@room.id}"].trigger "team_a_score", game_logic.showable_team_a_score
      ::WebsocketRails[:"room#{@room.id}"].trigger "team_b_score", game_logic.showable_team_b_score
    end

    # @param room [Room]
    # @return boolean
    def memorable_game?(room)
      # @type [Array<RoomPlayer>]
      room_players = room.room_players

      room_players.length > 0 &&
      # Should be an even number of players
          room_players.length % 2 === 0 &&
          room_players.length == room.player_count &&
      # Somebody should have points
          (room.team_a_score > 0 || room.team_b_score > 0) &&
          !room.game_session_id.nil?
    end

    # @param room [Room]
    def save_history(room)
      room_players = @room.room_players

      # @type [Array<RoomPlayer>]
      team_a_players = room_players.select {|room_player| room_player.team == PlayersController::TEAM_A_ID}
      # @type [Array<RoomPlayer>]
      team_b_players = room_players.select {|room_player| room_player.team == PlayersController::TEAM_B_ID}

      # We should batch this but ActiveRecord makes it a pain in the ass and I don't care that much
      # @type [Array<GameHistory>]
      histories = []
      # @type [Array<Player>]
      winning_players = []
      # @type [Array<Player>]
      losing_players = []
      if room.team_a_score > room.team_b_score
        # Yay for team A
        team_a_players.each do |room_player|
          history = new_game_history(room, room_player, true)
          histories << history
          winning_players << Player.find_by(:id => room_player.player_id)
        end
        team_b_players.each do |room_player|
          history = new_game_history(room, room_player, false)
          histories << history
          losing_players << Player.find_by(:id => room_player.player_id)
        end
      else
        team_a_players.each do |room_player|
          history = new_game_history(room, room_player, false)
          histories << history
          winning_players << Player.find_by(:id => room_player.player_id)
        end
        # All glory to team B
        team_b_players.each do |room_player|
          history = new_game_history(room, room_player, true)
          histories << history
          losing_players << Player.find_by(:id => room_player.player_id)
        end
      end

      # Use the first player's history PK as the game ID because it's an easy way to generate a unique, sequential integer
      game_id = histories[0].id
      histories.each do |history|
        history.update_attributes(game_id: game_id)
      end

      # Update skills
      margin = (room.team_a_score - room.team_b_score).abs
      manager = RatingManager.new
      manager.process_game(winning_players, margin, losing_players, -margin)
      winning_players.each { |player| player.save }
      losing_players.each { |player| player.save }
    end

    # @param room [Room]
    # @param room_player [RoomPlayer]
    # @param win [boolean]
    # @return [GameHistory]
    def new_game_history(room, room_player, win)
      game_history = GameHistory.new(
          room_id: @room.id,
          player_id: room_player.player_id,
          game_session_id: room.game_session_id,
          player_count: room.player_count,
          win: win
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

    def should_reset?
      return GameLogic.new(@room.team_a_score, @room.team_b_score).game_over?
    end


    # Use callbacks to share common setup or constraints between actions.
    def set_room
      @room = Room.find(params[:id]) rescue Room.find(params[:room_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def room_params
      params.require(:room).permit(:client_token, :name)
    end

    def private_game_end_post
      if memorable_game?(@room)
        save_history(@room)
      end

      @room.update_attributes(team_a_score: 0, team_b_score: 0, game: false)
      if params[:quit].present?
        @room.room_players.delete_all
        @room.update_attribute(:game_session_id, nil)
      else
        @room.update_attributes(team_a_score: 0, team_b_score: 0, game: true)
        @room.room_players.each do |room_player|
          if room_player.team == "a"
            room_player.update_attribute(:team, "b")
          elsif room_player.team == "b"
            room_player.update_attribute(:team, "a")
          end
        end

      end
    end

end
