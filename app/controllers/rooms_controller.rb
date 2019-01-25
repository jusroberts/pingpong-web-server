require 'time'

class RoomsController < ApplicationController
  before_action :set_room, except: [:index, :new, :create, :home]
  before_action :show_topbar, only: [:home]

  VALID_PLAYER_COUNTS = [2, 4]

  #-------------------------------------------------------- START API--------------------------------------------------

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
    if @room.handle_request_id(params[:request_id].to_i) == false
      #ignore old requests
      return
    end

    if should_reset?
      @room.update_attributes(game: false, team_a_score: 0, team_b_score: 0, streak: 0, streak_history: "")
      private_game_end_post
      ::WebsocketRails[:"room#{@room.id}"].trigger "new_game_refresh"
      return
    end

    team = params[:team].downcase
    unless ['a', 'b'].include?(team)
      raise "Invalid team #{team} passed to increment score function"
    end

    # Times when this call shouldn't happen
    if @room.increment_at && @room.increment_at > 1.seconds.ago
      return
    end
    raise("invalid team") if params[:team].downcase != 'a' && params[:team].downcase != 'b'
    @room.update_attribute(:increment_at, Time.now)

    if @room.game
      if should_reset?
        @room.update_attributes(team_a_score: 0, team_b_score: 0, streak: 0, streak_history: "")
      else
        current_score = @room.method("team_#{team}_score".to_sym).call()
        @room.update_attribute("team_#{team}_score", current_score + 1)
        @room.update_streak(true, team)
      end
      set_room
    end
    send_scores
    render nothing: true
  end

  # /api/rooms/1/team/a/decrement
  def decrement_score
    if @room.handle_request_id(params[:request_id].to_i) == false
      #ignore old requests
      return
    end

    team = params[:team].downcase
    unless ['a', 'b'].include?(team)
      raise "Invalid team #{team} passed to increment score function"
    end

    # Times when this call shouldn't happen
    # Just use the increment_at time to debounce decrement as well
    if @room.increment_at && @room.increment_at > 1.seconds.ago
      return
    end
    raise("invalid team") if params[:team].downcase != 'a' && params[:team].downcase != 'b'
    @room.update_attribute(:increment_at, Time.now)

    should_reload = false
    if @room.game
      current_score = @room.method("team_#{team}_score".to_sym).call()
      if current_score > 0
        if GameLogic.new(@room.team_a_score, @room.team_b_score).game_over?
          #If the game is already over and a decrement is called,
          # then decrement the score and refresh the game to stop it from ending.
          should_reload = true
        end
        @room.update_attribute(:game, true)
        @room.update_attribute("team_#{team}_score", current_score - 1)
        @room.update_streak(false, team)
      end
      set_room
    end
    send_scores
    if should_reload
      ::WebsocketRails[:"room#{@room.id}"].trigger "new_game_refresh"
    end
    render nothing: true
  end

  def taunt
    if @room.handle_request_id(params[:request_id].to_i) == false
      #ignore old requests
      return
    end

    team = params[:team].downcase
    unless ['a', 'b'].include?(team)
      raise "Invalid team #{team} passed to increment score function"
    end

    # Times when this call shouldn't happen
    # Just use the increment_at time to debounce taunt as well
    if @room.increment_at && @room.increment_at > 1.seconds.ago
      return
    end

    if @room.game
      ::WebsocketRails[:"room#{@room.id}"].trigger "taunt", team
    end
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

  #/api/rooms/1/end
  def end_game
    if @room.client_token == params[:code]
      ::WebsocketRails[:"room#{@room.id}"].trigger "end_game"
    end
    render :json => {}
  end

  # /api/rooms/1/activeseason
  def active_season
    active_season = @room.get_active_season
    render :json => {:id => active_season.id, :name => active_season.name}
  end

  #-------------------------------------------------------- END API----------------------------------------------------

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

    @player_ids = load_player_ids(@room, @player_count, true)

    @player_a_1_url ||= "/images/pong_assets/pong_avatar 1 doubles.png"
    @player_a_2_url ||= "/images/pong_assets/pong_avatar 1 doubles.png"
    @player_b_1_url ||= "/images/pong_assets/pong_avatar 2 doubles.png"
    @player_b_2_url ||= "/images/pong_assets/pong_avatar 2 doubles.png"
    # @player_ids = JSON.encode(@player_ids)
    @player_ids = @player_ids.to_json
  end

  def game_new_post

    @room.update_attributes(game: true, team_a_score: 0, team_b_score: 0, streak: 0, streak_history: "", start_time: Time.now, end_time: nil)

    redirect_to :room_game_play

    # Generate a new game session id
    @room.update_attributes(game_session_id: SecureRandom.base64(16))
  end

  def game_end_post
    @room.update_attributes(end_time: Time.now)
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

  def leaderboard
    season_id = @room.get_active_season.id
    ignore_deviation = params.key? :ignore_deviation
    if params.key? :game_type
      game_type = params[:game_type].to_i
    end
    if game_type != 1
      game_type = 2
    end
    if ignore_deviation
      @allPlayerRatings = PlayerDao::get_leaderboard_player_ratings(season_id, game_type, RatingManager::TRUESKILL_SIGMA, 500)
    else
      @allPlayerRatings = PlayerDao::get_leaderboard_player_ratings(season_id, game_type, PlayerDao::LEADERBOARD_DEVIATION_CUTOFF, 50)
    end
    @player_ratings = []
    @allPlayerRatings.each do |player_rating|
      if ignore_deviation || player_rating.deviation < PlayerDao::LEADERBOARD_DEVIATION_CUTOFF
        @player_ratings << player_rating
      end
    end
    @player_ratings
  end
  
  private

    # @param room [Room]
    # @param player_count [Integer]
    # @param set_image_urls [Boolean]
    # @return [Hash{String => Array<Number>}]
    def load_player_ids(room, player_count, set_image_urls = false)
      player_ids = {
          :a => [],
          :b => []
      }
      room_players_by_id = room.room_players.to_a.index_by {|rp| "#{rp.team}_#{rp.player_number}"}
      teams = [:a, :b]
      if player_count == 2
        # Singles
        player_numbers = [1]
      elsif player_count == 4
        # Doubles
        player_numbers = [1, 2]
      else
        raise "Invalid player count #{player_count}"
      end

      teams.each do |team|
        player_numbers.each do |player_number|
          key = "#{team}_#{player_number}"
          if room_players_by_id.has_key?(key)
            player_id = room_players_by_id[key].player_id
            # @type [Player]
            player_ids[team] << player_id
            if set_image_urls
              player = Player.find_by id: player_id
              instance_variable_set("@player_#{key}_url", player.image_url)
            end
          end
        end
      end
      player_ids
    end

    def set_current_game_status
      game_logic = GameLogic.new(@room.team_a_score, @room.team_b_score)
      @team_a_score = game_logic.showable_team_a_score
      @team_b_score = game_logic.showable_team_b_score

      @team_b_status = @team_b_score == "W" ? "WINNER!" : "&nbsp;".html_safe
      @team_a_status = @team_a_score == "W" ? "WINNER!" : "&nbsp;".html_safe

      player_id_hash = load_player_ids(@room, @room.player_count)
      @player_ids = player_id_hash.to_json
      actual_player_ids = player_id_hash[:a] + player_id_hash[:b]
      @player_rankings = RankingHelper::get_player_rankings(actual_player_ids)

      @audio_filenames = {}
      Dir["public/audio/*"].each do |path|
        # Some hanky-panky to lose the "public" prefix
        server_path = File.join(Pathname(path).each_filename.to_a[1..-1])
        @audio_filenames[File.basename(path, '.mp3')] = server_path
      end
    end

    def send_scores
      set_room
      game_logic = GameLogic.new(@room.team_a_score, @room.team_b_score)
      ::WebsocketRails[:"room#{@room.id}"].trigger "score_update", {
          :teamAScore => game_logic.showable_team_a_score,
          :teamBScore => game_logic.showable_team_b_score,
          :streak => @room.streak,
      }
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
      puts("End game request received: #{request.inspect}")
      @room.end_game(params[:quit].present?, @room)
    end

end
