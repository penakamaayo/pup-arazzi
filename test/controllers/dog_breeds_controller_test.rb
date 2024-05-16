require "test_helper"

class DogBreedsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get dog_breeds_index_url
    assert_response :success
  end
end
