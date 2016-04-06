class RoomsController < ApplicationController
  before_action :set_room, only: [:show, :edit, :update, :destroy, :increment_score]

  # GET /rooms
  # GET /rooms.json
  def index
    @rooms = Room.all
  end

  # GET /rooms/1
  # GET /rooms/1.json
  def show
    game_logic = GameLogic.new(@room.team_a_score, @room.team_b_score)
    @team_a_score = game_logic.showable_team_a_score
    @team_b_score = game_logic.showable_team_b_score

    @team_a_status = @team_a_score == "W" ? "WINNER" : "&nbsp;".html_safe
    @team_b_status = @team_b_score == "W" ? "WINNER" : "&nbsp;".html_safe
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
    if should_reset?
      @room.update_attributes(team_a_score: 0, team_b_score: 0)
    else
      current_score = @room.method("team_#{team}_score".to_sym).call()
      @room.update_attribute("team_#{team}_score", current_score + 1)
    end
    send_scores
    render nothing: true
  end

  private

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
      @room = Room.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def room_params
      params.require(:room).permit(:client_token, :name)
    end
end
