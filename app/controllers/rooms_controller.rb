class RoomsController < ApplicationController
  before_action :set_room, only: [:show, :edit, :update,
                                  :destroy, :increment_score, :room_status,
                                  :game_new_post, :game_view, :game_play, :game_end_post, :game_newfull, :game_player_count_post,
                                  :interstitial]

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

  # /rooms/1/team/a/increment
  def increment_score
    team = params[:team].downcase
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
    render nothing: true
  end

  def room_status
    render :json => {
        :team_a_score => @room.team_a_score,
        :team_b_score => @room.team_b_score,
        :name => @room.name,
        :has_active_game => @room.game
    }
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
    render :json => {
        :player_count => count
    }
  end

  def game_newfull
    @id = params[:id] || params[:room_id]
    @player_count = @room.player_count
    # Team A.1
    @player_a_1_url = nil
    # Team A.2
    @player_a_2_url = nil
    # Team B.1
    @player_b_1_url = nil
    # Team B.2
    @player_b_2_url = nil

    room_players_by_id = @room.room_players.to_a.index_by {|rp| "#{rp.team}_#{rp.player_number}"}

    if @player_count == 2
      # Singles
      load_indexed_player_image_url(room_players_by_id, 'a_1')
      load_indexed_player_image_url(room_players_by_id, 'b_1')
    elsif @player_count == 4
      # Doubles
      load_indexed_player_image_url(room_players_by_id, 'a_1')
      load_indexed_player_image_url(room_players_by_id, 'a_2')
      load_indexed_player_image_url(room_players_by_id, 'b_1')
      load_indexed_player_image_url(room_players_by_id, 'b_2')
    else
      # Wat
      raise("Invalid player count #{@player_count}")
    end

    @player_a_1_url ||= "/images/pong_assets/pong_avatar 1 doubles.png"
    @player_a_2_url ||= "/images/pong_assets/pong_avatar 1 doubles.png"
    @player_b_1_url ||= "/images/pong_assets/pong_avatar 2 doubles.png"
    @player_b_2_url ||= "/images/pong_assets/pong_avatar 2 doubles.png"
  end

  def game_new_post
    @room.update_attributes(team_a_score: 0, team_b_score: 0, game: true)
    redirect_to :room_game_play
  end

  def game_end_post
    @room.update_attributes(team_a_score: 0, team_b_score: 0, game: false)
    @room.room_players.delete_all
    # binding.pry
    if params[:quit].present?
      redirect_to :room_game_interstitial
    else
      @room.update_attributes(team_a_score: 0, team_b_score: 0, game: true)
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

  private

    def load_indexed_player_image_url(room_players_by_id, key)
      if room_players_by_id.has_key?(key)
        player = Player.find_by id: room_players_by_id[key].player_id
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
      ::WebsocketRails[:"room#{params[:id]}"].trigger "team_a_score", game_logic.showable_team_a_score
      ::WebsocketRails[:"room#{params[:id]}"].trigger "team_b_score", game_logic.showable_team_b_score
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
end
