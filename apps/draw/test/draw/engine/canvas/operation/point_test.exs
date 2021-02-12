defmodule Draw.Engine.Canvas.Operation.PointTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Draw.Engine.Canvas
  alias Draw.Engine.Canvas.Operation
  alias Draw.Engine.Canvas.Operation.Point

  describe "process/2" do
    test "adds point to canvas" do
      canvas = Canvas.new()
      point = %Point{point: {1, 2}, character: "A"}

      assert {:ok, canvas} = Operation.process(point, canvas)
      assert Canvas.at(canvas, {1, 2}) == "A"
    end

    test "doesn't add point if out of bounds" do
      canvas = Canvas.new(2, 2)
      point = %Point{point: {2, 2}, character: "A"}
      assert {:error, :out_of_bounds} = Operation.process(point, canvas)
    end

    property "adds random point to canvas" do
      check all width <- integer(1..100),
                height <- integer(1..100),
                character <- string(:ascii, min_length: 1, max_length: 1),
                x <- integer(0..(width - 1)),
                y <- integer(0..(height - 1)),
                canvas = Canvas.new(width, height, " "),
                point = %Point{point: {x, y}, character: character} do
        assert {:ok, canvas} = Operation.process(point, canvas)

        for i <- 0..(width - 1), j <- 0..(height - 1), i != x && j != y do
          assert Canvas.at(canvas, {i, j}) == " "
        end

        assert Canvas.at(canvas, {x, y}) == character
      end
    end
  end
end
