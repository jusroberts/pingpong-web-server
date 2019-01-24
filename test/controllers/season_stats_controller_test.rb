require 'test_helper'

class SeasonStatsControllerTest < ActionController::TestCase
  setup do
    @season_stat = season_stats(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:season_stats)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create season_stat" do
    assert_difference('SeasonStat.count') do
      post :create, season_stat: { average_loss_margin: @season_stat.average_loss_margin, average_win_margin: @season_stat.average_win_margin, has_completed_aggregation: @season_stat.has_completed_aggregation, losses: @season_stat.losses, most_defeated_by_player_id: @season_stat.most_defeated_by_player_id, most_defeated_player_id: @season_stat.most_defeated_player_id, player_count: @season_stat.player_count, player_id: @season_stat.player_id, season_id: @season_stat.season_id, total_points_scored: @season_stat.total_points_scored, total_points_scored_against: @season_stat.total_points_scored_against, wins: @season_stat.wins }
    end

    assert_redirected_to season_stat_path(assigns(:season_stat))
  end

  test "should show season_stat" do
    get :show, id: @season_stat
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @season_stat
    assert_response :success
  end

  test "should update season_stat" do
    patch :update, id: @season_stat, season_stat: { average_loss_margin: @season_stat.average_loss_margin, average_win_margin: @season_stat.average_win_margin, has_completed_aggregation: @season_stat.has_completed_aggregation, losses: @season_stat.losses, most_defeated_by_player_id: @season_stat.most_defeated_by_player_id, most_defeated_player_id: @season_stat.most_defeated_player_id, player_count: @season_stat.player_count, player_id: @season_stat.player_id, season_id: @season_stat.season_id, total_points_scored: @season_stat.total_points_scored, total_points_scored_against: @season_stat.total_points_scored_against, wins: @season_stat.wins }
    assert_redirected_to season_stat_path(assigns(:season_stat))
  end

  test "should destroy season_stat" do
    assert_difference('SeasonStat.count', -1) do
      delete :destroy, id: @season_stat
    end

    assert_redirected_to season_stats_path
  end
end
