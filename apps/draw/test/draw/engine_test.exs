defmodule Draw.EngineTest do
  use ExUnit.Case
  alias Draw.Engine
  alias Draw.Engine.Canvas

  describe "new_canvas/1" do
    test "creates a new canvas" do
      assert Engine.new_canvas({1, 1}) == Canvas.new(1, 1)
    end

    test "creates a new canvas with default size" do
      assert Engine.new_canvas() == Canvas.new(32, 12, " ")
    end
  end
end
