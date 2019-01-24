class PlayerRatingsController < ApplicationController
  before_action :set_player_rating, only: [:show, :edit, :update, :destroy]

  # GET /player_ratings
  # GET /player_ratings.json
  def index
    @player_ratings = PlayerRating.all
  end

  # GET /player_ratings/1
  # GET /player_ratings/1.json
  def show
  end

  # GET /player_ratings/new
  def new
    @player_rating = PlayerRating.new
  end

  # GET /player_ratings/1/edit
  def edit
  end

  # POST /player_ratings
  # POST /player_ratings.json
  def create
    @player_rating = PlayerRating.new(player_rating_params)

    respond_to do |format|
      if @player_rating.save
        format.html { redirect_to @player_rating, notice: 'Player rating was successfully created.' }
        format.json { render :show, status: :created, location: @player_rating }
      else
        format.html { render :new }
        format.json { render json: @player_rating.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /player_ratings/1
  # PATCH/PUT /player_ratings/1.json
  def update
    respond_to do |format|
      if @player_rating.update(player_rating_params)
        format.html { redirect_to @player_rating, notice: 'Player rating was successfully updated.' }
        format.json { render :show, status: :ok, location: @player_rating }
      else
        format.html { render :edit }
        format.json { render json: @player_rating.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /player_ratings/1
  # DELETE /player_ratings/1.json
  def destroy
    @player_rating.destroy
    respond_to do |format|
      format.html { redirect_to player_ratings_url, notice: 'Player rating was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_player_rating
      @player_rating = PlayerRating.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def player_rating_params
      params.require(:player_rating).permit(:player_id, :season_id, :skill, :deviation)
    end
end
