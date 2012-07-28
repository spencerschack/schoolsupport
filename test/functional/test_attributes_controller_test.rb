require 'test_helper'

class TestAttributesControllerTest < ActionController::TestCase
  setup do
    @test_attribute = test_attributes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:test_attributes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create test_attribute" do
    assert_difference('TestAttribute.count') do
      post :create, test_attribute: { name: @test_attribute.name }
    end

    assert_redirected_to test_attribute_path(assigns(:test_attribute))
  end

  test "should show test_attribute" do
    get :show, id: @test_attribute
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @test_attribute
    assert_response :success
  end

  test "should update test_attribute" do
    put :update, id: @test_attribute, test_attribute: { name: @test_attribute.name }
    assert_redirected_to test_attribute_path(assigns(:test_attribute))
  end

  test "should destroy test_attribute" do
    assert_difference('TestAttribute.count', -1) do
      delete :destroy, id: @test_attribute
    end

    assert_redirected_to test_attributes_path
  end
end
