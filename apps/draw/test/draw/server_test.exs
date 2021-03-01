defmodule Draw.ServerTest do
  use Draw.DataCase

  describe "start_link/1" do
    test "starts a server and broadcasts pubsub message" do
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
