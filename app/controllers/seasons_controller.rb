class SeasonsController < ApplicationController
  before_action :set_season, only: [:show, :edit, :update, :destroy, :leaderboard]
  before_action :set_room

  # GET /seasons
  # GET /seasons.json
  def index
    @seasons = @room.seasons
  end

  # GET /seasons/1
  # GET /seasons/1.json
  def show
  end

  # GET /seasons/new
  def new
    @season = Season.new
  end

  # GET /seasons/1/edit
  def edit
  end

  # POST /seasons
  # POST /seasons.json
  def create
    @season = Season.new(season_params)

    respond_to do |format|
      if @season.save
        format.html { redirect_to room_seasons_url, notice: 'Season was successfully created.' }
        format.json { render :show, status: :created, location: @season }
      else
        format.html { render :new }
        format.json { render json: @season.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /seasons/1
  # PATCH/PUT /seasons/1.json
  def update
    respond_to do |format|
      if @season.update(season_params)
        format.html { redirect_to [@room, @season], notice: 'Season was successfully updated.' }
        format.json { render :show, status: :ok, location: @season }
      else
        format.html { render :edit }
        format.json { render json: @season.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /seasons/1
  # DELETE /seasons/1.json
  def destroy
    @season.destroy
    respond_to do |format|
      format.html { redirect_to room_seasons_url, notice: 'Season was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def leaderboard
    season_id = @season.id
    ignore_deviation = params.key? :ignore_deviation
		if params.key? :game_type
      game_type = params[:game_type].to_i
    end
    if game_type != 1
      game_type = 2
    end
    if ignore_deviation
      @allPlayerRatingss = PlayerDao::get_leaderboard_player_ratings(season_id, game_type, RatingManager::TRUESKILL_SIGMA, 500)
    else
      @allPlayerRatingss = PlayerDao::get_leaderboard_player_ratings(season_id, game_type, PlayerDao::LEADERBOARD_DEVIATION_CUTOFF, 50)
    end
    @player_ratings = []
    @allPlayerRatingss.each do |player_rating|
      if ignore_deviation || player_rating.deviation < PlayerDao::LEADERBOARD_DEVIATION_CUTOFF
        @player_ratings << player_rating
      end
    end
    @player_ratings
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_season
      @season = Season.find(params[:id]) rescue Season.find(params[:season_id])
    end

    def set_room
      @room = Room.find(params[:room_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def season_params
      var = params.require(:season).permit(:name, :active)
      var[:room_id] = @room.id
      var
    end
end
