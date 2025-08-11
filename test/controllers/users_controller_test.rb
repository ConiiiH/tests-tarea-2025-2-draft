require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, name: "Pedro Pascal", email: "pedrito@example.com")
  end

  test "GET /users retorna todos los usuarios" do
    get "/users"
    assert_response :success
    assert_equal 1, json_response.size
  end

  test "POST /users crea usuario válido" do
    assert_difference("User.count", 1) do
      post "/users", params: {
        user: { 
          name: "Ana", 
          email: "ana@example.com" }
      }
    end
    assert_response :created
  end

  test "POST /users falla sin email" do
    post "/users", params: { user: { name: "Sin Email" } }
    assert_response :unprocessable_entity
  end

  test "DELETE /users/:id elimina usuario existente" do
    assert_difference("User.count", -1) do
      delete "/users/#{@user.id}"
    end
    assert_response :no_content
  end

  test "DELETE /users elimina todos los usuarios" do
    create_list(:user, 3)
    assert_difference("User.count", -4) do
      delete "/users"
    end
    assert_response :ok
  end

  test "GET /users/:id retorna usuario existente" do
    get "/users/999"
    assert_response :not_found
  end

  test "GET /users/:id retorna 404 para id inexistente" do
    get "/users/999"
    assert_response :not_found
  end

  test "POST /users/:user_id/subscribe/:calendar_id suscribe usuario a calendario" do
    calendar = create(:calendar)
    post "/users/#{@user.id}/subscribe/#{calendar.id}"
    assert_response :success
    assert_includes @user.reload.calendars, calendar
  end

  test "POST /users/:user_id/subscribe/:calendar_id retorna 404 si calendario no existe" do
    post "/users/#{@user.id}/subscribe/999"
    assert_response :not_found
  end

end
