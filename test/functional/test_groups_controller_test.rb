require 'test_helper'

class TestGroupsControllerTest < ActionController::TestCase
  setup do
    @test_group = test_groups(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:test_groups)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create test_group" do
    assert_difference('TestGroup.count') do
      post :create, test_group: { name: @test_group.name }
    end

    assert_redirected_to test_group_path(assigns(:test_group))
  end

  test "should show test_group" do
    get :show, id: @test_group
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @test_group
    assert_response :success
  end

  test "should update test_group" do
    put :update, id: @test_group, test_group: { name: @test_group.name }
    assert_redirected_to test_group_path(assigns(:test_group))
  end

  test "should destroy test_group" do
    assert_difference('TestGroup.count', -1) do
      delete :destroy, id: @test_group
    end

    assert_redirected_to test_groups_path
  end
end
