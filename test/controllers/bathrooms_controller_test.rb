require 'test_helper'

class BathroomsControllerTest < ActionController::TestCase
  setup do
    @bathroom = bathrooms(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:bathrooms)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create bathroom" do
    assert_difference('Bathroom.count') do
      post :create, bathroom: { name: "TestName", token: "TestToken" }
    end

    assert_redirected_to bathroom_path(assigns(:bathroom))
  end

  test "should show bathroom" do
    get :show, id: @bathroom
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @bathroom
    assert_response :success
  end

  test "should update bathroom" do
    patch :update, id: @bathroom, bathroom: { name: "NewName", token: "NewToken" }
    assert_redirected_to bathroom_path(assigns(:bathroom))
  end

  test "should destroy bathroom" do
    assert_difference('Bathroom.count', -1) do
      delete :destroy, id: @bathroom
    end

    assert_redirected_to bathrooms_path
  end
end
