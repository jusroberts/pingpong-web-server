class SeasonStatsController < ApplicationController
  before_action :set_season_stat, only: [:show, :edit, :update, :destroy]

  # GET /season_stats
  # GET /season_stats.json
  def index
    @season_stats = SeasonStat.all
  end

  # GET /season_stats/1
  # GET /season_stats/1.json
  def show
  end

  # GET /season_stats/new
  def new
    @season_stat = SeasonStat.new
  end

  # GET /season_stats/1/edit
  def edit
  end

  # POST /season_stats
  # POST /season_stats.json
  def create
    @season_stat = SeasonStat.new(season_stat_params)

    respond_to do |format|
      if @season_stat.save
        format.html { redirect_to @season_stat, notice: 'Season stat was successfully created.' }
        format.json { render :show, status: :created, location: @season_stat }
      else
        format.html { render :new }
        format.json { render json: @season_stat.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /season_stats/1
  # PATCH/PUT /season_stats/1.json
  def update
    respond_to do |format|
      if @season_stat.update(season_stat_params)
        format.html { redirect_to @season_stat, notice: 'Season stat was successfully updated.' }
        format.json { render :show, status: :ok, location: @season_stat }
      else
        format.html { render :edit }
        format.json { render json: @season_stat.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /season_stats/1
  # DELETE /season_stats/1.json
  def destroy
    @season_stat.destroy
    respond_to do |format|
      format.html { redirect_to season_stats_url, notice: 'Season stat was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_season_stat
      @season_stat = SeasonStat.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def season_stat_params
      params.require(:season_stat).permit(:player_id, :season_id, :has_completed_aggregation, :player_count, :wins, :losses, :most_defeated_player_id, :most_defeated_by_player_id, :average_win_margin, :average_loss_margin, :total_points_scored, :total_points_scored_against)
    end
end
