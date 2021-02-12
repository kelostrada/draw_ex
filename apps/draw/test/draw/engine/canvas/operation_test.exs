defmodule Draw.Engine.Canvas.OperationTest do
  use ExUnit.Case
  alias Draw.Engine.Canvas
  alias Draw.Engine.Canvas.Operation
  alias Draw.Engine.Canvas.Operation.Noop

  describe "process/2" do
    test "Proceed with noop (no changes)" do
      canvas = Canvas.new()
      assert Operation.process(%Noop{}, canvas) == {:ok, canvas}
    end
  end
end
