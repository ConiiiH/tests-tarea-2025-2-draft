require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @calendar = create(:calendar)
    @event = create(:event, calendar: @calendar, title: "Interrogacion 1", date: "2025-09-26T00:00:00Z")
  end

  test "POST /events/:calendar_id crea evento válido" do
    assert_difference("Event.count", 1) do
      post "/events/#{@calendar.id}", params: {
        event: { title: "Nueva Ayudantia", date: "2025-10-01T00:00:00Z" }
      }
    end
    assert_response :created
  end

  test "POST /events/:calendar_id falla sin título" do
    post "/events/#{@calendar.id}", params: { event: { date: "2025-10-01T00:00:00Z" } }
    assert_response :unprocessable_entity
  end

  test "DELETE /events/:id elimina evento existente" do
    assert_difference("Event.count", -1) do
      delete "/events/#{@event.id}"
    end
    assert_response :no_content
  end

  test "GET /events/:calendar_id retorna eventos del calendario" do
    get "/events/#{@calendar.id}"
    assert_response :success
    assert_equal 1, json_response.size
  end

  test "PATCH /events/:id actualiza evento" do
    patch "/events/#{@event.id}", params: { event: { date: "2026-09-26T00:00:00Z" } }
    assert_response :success
    assert_equal "2026-09-26T00:00:00Z", json_response["date"]
  end

  test "GET /events/next/:calendar_id retorna evento próximo" do
    post "/events/#{@calendar.id}", params: { event: { title: "Más cercano", date: "2025-09-25T00:00:00Z" } }
    post "/events/#{@calendar.id}", params: { event: { title: "Más lejano", date: "2025-09-30T00:00:00Z" } }

    get "/events/next/#{@calendar.id}", params: { nearDate: "2025-09-24T00:00:00Z" }
    assert_response :success
    assert_equal "Más cercano", json_response["title"]
  end

  test "GET /events/next3/:user_id retorna 3 eventos próximos ordenados" do
    user = create(:user)
    calendar2 = create(:calendar)
    post "/users/#{user.id}/subscribe/#{@calendar.id}"
    post "/users/#{user.id}/subscribe/#{calendar2.id}"

    create(:event, calendar: @calendar, title: "B", date: "2025-09-27T00:00:00Z")
    create(:event, calendar: @calendar, title: "A", date: "2025-09-27T00:00:00Z")
    create(:event, calendar: calendar2, title: "C", date: "2025-09-28T00:00:00Z")

    get "/events/next3/#{user.id}", params: { nearDate: "2025-09-25T00:00:00Z" }
    assert_response :success
    events = json_response
    assert_equal 3, events.size
    assert_equal ["A", "B", "C"], events.map { |e| e["title"] }.sort
  end
end
