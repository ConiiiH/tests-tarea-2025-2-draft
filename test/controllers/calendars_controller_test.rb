require "test_helper"
require 'calendar'


class CalendarsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @calendar = create(:calendar, name: "Programacion_IIC2143", description: "Fechas de pruebas y tareas")
  end

  test "GET /calendars debe retornar todos los calendarios" do
    get "/calendars"
    assert_response :success
    calendars = json_response
    assert_equal 1, calendars.size
    assert_equal "Programacion_IIC2143", calendars.first["name"]
  end

  test "GET /calendars/:id retorna calendario existente" do
    get "/calendars/#{@calendar.id}"
    assert_response :success
    assert_equal @calendar.name, json_response["name"]
  end

  test "GET /calendars/:id retorna 404 para id inexistente" do
    get "/calendars/999"
    assert_response :not_found
  end

  test "POST /calendars crea calendario válido" do
    assert_difference("Calendar.count", 1) do
      post "/calendars", params: {
        calendar: { name: "Nuevo_Calendario", description: "Descripción ejemplo" }
      }
    end
    assert_response :created
    assert_equal "Nuevo_Calendario", json_response["name"]
  end

  test "POST /calendars falla sin nombre" do
    post "/calendars", params: { calendar: { description: "Sin nombre" } }
    assert_response :unprocessable_entity
  end

  test "DELETE /calendars/:id elimina calendario y sus eventos" do
    create(:event, calendar: @calendar)
    assert_difference("Calendar.count", -1) do
      delete "/calendars/#{@calendar.id}"
    end
    assert_response :no_content
    assert_equal 0, Event.where(calendar_id: @calendar.id).count
  end

  test "DELETE /calendars elimina todos los calendarios" do
    create_list(:calendar, 3)
    assert_difference("Calendar.count", -4) do
      delete "/calendars"
    end
    assert_response :ok
  end
end
