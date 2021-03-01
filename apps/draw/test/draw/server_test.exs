defmodule Draw.ServerTest do
  use Draw.DataCase
  import ExUnit.CaptureLog
  alias Draw.Persistence
  alias Draw.Server

  @valid_attrs %{fields: "  \n  \n", height: 2, width: 2}

  def canvas_fixture(attrs \\ %{}) do
    {:ok, canvas} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Persistence.create_canvas()

    canvas
  end

  describe "start_link/1" do
    test "starts a server and broadcasts pubsub message" do
      %{id: canvas_id} = canvas_fixture()
      Phoenix.PubSub.subscribe(Draw.PubSub, "canvas:#{canvas_id}")

      assert {:ok, pid} = Server.start_link(canvas_id: canvas_id)
      assert %{canvas_id: ^canvas_id} = :sys.get_state(pid)
      assert_receive {:canvas_update, canvas}
      assert "  \n  \n" == to_string(canvas)
    end

    test "doesn't start because canvas_id not provided" do
      assert {:error, :missing_canvas_id} == Server.start_link([])
    end

    test "doesn't start because canvas doesn't exist" do
      assert {:error, :not_found} == Server.start_link(canvas_id: Ecto.UUID.generate())
    end

    test "doesn't start because wrong canvas format" do
      %{id: canvas_id} = canvas_fixture(fields: "AAAAAAA")
      assert {:error, :wrong_format} == Server.start_link(canvas_id: canvas_id)
    end
  end

  describe "get_canvas/1" do
    test "gets canvas" do
      %{id: canvas_id} = canvas_fixture(width: 1, height: 1, fields: "A\n")
      assert {:ok, _pid} = Server.start_link(canvas_id: canvas_id)
      assert %{fields: %{{0, 0} => 65}} = Server.get_canvas(canvas_id)
    end
  end

  describe "draw_point/3" do
    test "draws point and persists data" do
      %{id: canvas_id} = canvas_fixture(width: 1, height: 1, fields: " \n")
      assert {:ok, _pid} = Server.start_link(canvas_id: canvas_id)
      assert {:ok, %{fields: %{{0, 0} => 65}}} = Server.draw_point(canvas_id, {0, 0}, "A")
      assert %{fields: "A\n"} = Persistence.get_canvas!(canvas_id)
    end

    test "fails to draw and keeps state" do
      %{id: canvas_id} = canvas_fixture(width: 1, height: 1, fields: " \n")
      assert {:ok, _pid} = Server.start_link(canvas_id: canvas_id)

      assert capture_log(fn ->
               assert {:error, :out_of_bounds} == Server.draw_point(canvas_id, {1, 1}, "A")
             end) =~ "Illegal operation %Draw.Engine.Canvas.Operation.Point"

      assert %{fields: %{{0, 0} => 32}} = Server.get_canvas(canvas_id)
      assert %{fields: " \n"} = Persistence.get_canvas!(canvas_id)
    end
  end

  describe "draw_rectangle/6" do
    test "draws rectangle and persists data" do
      %{id: canvas_id} = canvas_fixture(width: 1, height: 1, fields: " \n")
      assert {:ok, _pid} = Server.start_link(canvas_id: canvas_id)
      assert {:ok, canvas} = Server.draw_rectangle(canvas_id, {0, 0}, 1, 1, "A", nil)
      assert %{fields: %{{0, 0} => 65}} = canvas
      assert %{fields: "A\n"} = Persistence.get_canvas!(canvas_id)
    end

    test "fails to draw and keeps state" do
      %{id: canvas_id} = canvas_fixture(width: 1, height: 1, fields: " \n")
      assert {:ok, _pid} = Server.start_link(canvas_id: canvas_id)

      assert capture_log(fn ->
               assert {:error, :out_of_bounds} ==
                        Server.draw_rectangle(canvas_id, {1, 1}, 1, 1, "A", nil)
             end) =~ "Illegal operation %Draw.Engine.Canvas.Operation.Rectangle"

      assert %{fields: %{{0, 0} => 32}} = Server.get_canvas(canvas_id)
      assert %{fields: " \n"} = Persistence.get_canvas!(canvas_id)
    end
  end

  describe "flood_fill/3" do
    test "flood fills and persists data" do
      %{id: canvas_id} = canvas_fixture(width: 1, height: 1, fields: " \n")
      assert {:ok, _pid} = Server.start_link(canvas_id: canvas_id)
      assert {:ok, canvas} = Server.flood_fill(canvas_id, {0, 0}, "A")
      assert %{fields: %{{0, 0} => 65}} = canvas
      assert %{fields: "A\n"} = Persistence.get_canvas!(canvas_id)
    end

    test "fails to flood fill and keeps state" do
      %{id: canvas_id} = canvas_fixture(width: 1, height: 1, fields: " \n")
      assert {:ok, _pid} = Server.start_link(canvas_id: canvas_id)

      assert capture_log(fn ->
               assert {:error, :out_of_bounds} ==
                        Server.flood_fill(canvas_id, {1, 1}, "A")
             end) =~ "Illegal operation %Draw.Engine.Canvas.Operation.FloodFill"

      assert %{fields: %{{0, 0} => 32}} = Server.get_canvas(canvas_id)
      assert %{fields: " \n"} = Persistence.get_canvas!(canvas_id)
    end
  end
end
