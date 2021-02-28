defmodule Draw.EngineTest do
  use ExUnit.Case
  import ExUnit.CaptureLog

  alias Draw.Engine
  alias Draw.Engine.Canvas
  alias Draw.Engine.Canvas.Operation.Failop
  alias Draw.Engine.Canvas.Operation.Noop

  describe "new_canvas/1" do
    test "creates a new canvas" do
      assert Engine.new_canvas({1, 1}) == Canvas.new(1, 1)
    end

    test "creates a new canvas with default size" do
      assert Engine.new_canvas() == Canvas.new(32, 12, " ")
    end
  end

  describe "load_canvas/2" do
    test "loads canvas from string" do
      canvas_string = "AB\nCD\n"
      assert {:ok, canvas} = Engine.load_canvas({2, 2}, canvas_string)
      assert to_string(canvas) == "AB\nCD\n"
    end
  end

  describe "apply_operation/2" do
    test "apply noop operation to the canvas (make no change)" do
      canvas = Canvas.new()
      assert Engine.apply_operation(canvas, %Noop{}) == {:ok, canvas}
    end

    test "applying failed operation will return error" do
      assert capture_log(fn ->
               assert Engine.apply_operation(Canvas.new(), %Failop{}) == {:error, :failed}
             end) =~ "Illegal operation %Draw.Engine.Canvas.Operation.Failop{} :failed"
    end
  end
end
