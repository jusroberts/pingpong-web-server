require 'test_helper'

class RoomsControllerTest < ActionController::TestCase
  setup do
    @room = rooms(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:rooms)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create room" do
    assert_difference('Room.count') do
      post :create, room: { client_token: @room.client_token, name: @room.name }
    end

    assert_redirected_to room_path(assigns(:room))
  end

  test "should show room" do
    get :show, id: @room
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @room
    assert_response :success
  end

  test "should update room" do
    patch :update, id: @room, room: { client_token: @room.client_token, name: @room.name }
    assert_redirected_to room_path(assigns(:room))
  end

  test "should destroy room" do
    assert_difference('Room.count', -1) do
      delete :destroy, id: @room
    end

    assert_redirected_to rooms_path
  end

  test "should increment team a" do
    assert_difference('Room.find(@room).team_a_score') do
      get :increment_score, id: @room, team: 'a'
      assert_response :success
    end
  end

  test "should increment team b" do
    assert_difference('Room.find(@room).team_b_score') do
      get :increment_score, id: @room, team: 'b'
      assert_response :success
    end
  end

  test "should increment invalid team" do
    assert_raises(RuntimeError, 'invalid team') do
      get :increment_score, id: @room, team: 'invalid'
      assert_response :failure
    end
  end

  test "should not reset the score when team_a wins" do
    @room.update_attribute('team_a_score', 20)
    assert_difference('Room.find(@room).team_a_score') do
      get :increment_score, id: @room, team: 'a'
    end
  end

  test "should reset the score after team_a wins" do
    @room.update_attribute('team_a_score', 21)
    get :increment_score, id: @room, team: 'a'
    @room = Room.find(@room)
    assert_equal(0, @room.team_a_score)
    assert_equal(0, @room.team_b_score)
  end

  test "should get scores less than 20" do
    skip("not implemented")
    set_scores(10, 11)
    get :score, id: @room
    binding.pry
    assert_true(false)
  end

end
