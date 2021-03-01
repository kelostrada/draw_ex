defmodule Draw.ServerTest do
  use Draw.DataCase
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
    end

    test "doesn't start because canvas doesn't exist" do
    end

    test "doesn't start because wrong canvas format" do
    end
  end

  describe "get_canvas/1" do
    test "gets canvas" do
    end
  end

  describe "draw_point/3" do
    test "draws point and persists data" do
    end

    test "fails to draw and keeps state" do
    end
  end

  describe "draw_rectangle/6" do
    test "draws rectangle and persists data" do
    end

    test "fails to draw and keeps state" do
    end
  end

  describe "flood_fill/3" do
    test "flood fills and persists data" do
    end

    test "fails to flood fill and keeps state" do
    end
  end
end
