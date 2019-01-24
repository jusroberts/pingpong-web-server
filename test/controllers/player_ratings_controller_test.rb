require 'test_helper'

class PlayerRatingsControllerTest < ActionController::TestCase
  setup do
    @player_rating = player_ratings(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:player_ratings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create player_rating" do
    assert_difference('PlayerRating.count') do
      post :create, player_rating: { deviation: @player_rating.deviation, player_id: @player_rating.player_id, season_id: @player_rating.season_id, skill: @player_rating.skill }
    end

    assert_redirected_to player_rating_path(assigns(:player_rating))
  end

  test "should show player_rating" do
    get :show, id: @player_rating
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @player_rating
    assert_response :success
  end

  test "should update player_rating" do
    patch :update, id: @player_rating, player_rating: { deviation: @player_rating.deviation, player_id: @player_rating.player_id, season_id: @player_rating.season_id, skill: @player_rating.skill }
    assert_redirected_to player_rating_path(assigns(:player_rating))
  end

  test "should destroy player_rating" do
    assert_difference('PlayerRating.count', -1) do
      delete :destroy, id: @player_rating
    end

    assert_redirected_to player_ratings_path
  end
end
