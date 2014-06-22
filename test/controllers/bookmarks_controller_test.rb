require 'test_helper'

class BookmarksControllerTest < ActionController::TestCase
  test "should get archive" do
    get :archive
    assert_response :success
  end

  test "should get like" do
    get :like
    assert_response :success
  end

end
