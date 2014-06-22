require 'test_helper'

class EmbedsControllerTest < ActionController::TestCase
  test "should get show" do
    get :show
    assert_response :success
  end

end
