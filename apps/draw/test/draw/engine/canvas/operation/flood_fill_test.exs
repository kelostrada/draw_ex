defmodule Draw.Engine.Canvas.Operation.FloodFillTest do
  use ExUnit.Case

  alias Draw.Engine.Canvas
  alias Draw.Engine.Canvas.Changes
  alias Draw.Engine.Canvas.Operation
  alias Draw.Engine.Canvas.Operation.FloodFill
  alias Draw.Engine.Canvas.Operation.Point
  alias Draw.Engine.Canvas.Operation.Rectangle

  @fixture3 """
  --------------.......
  --------------.......
  --------------.......
  OOOOOOOO------.......
  O      O------.......
  O    XXXXX----.......
  OOOOOXXXXX-----------
       XXXXX-----------
  """

  describe "known fixtures" do
    test "fixture 3" do
      canvas = Canvas.new(21, 8)
      rectangle = Rectangle.new({14, 0}, 7, 6, fill: ".")
      assert {:ok, changes} = Operation.process(rectangle, canvas)
      assert {:ok, canvas} = Canvas.apply_changes(canvas, changes)
      rectangle = Rectangle.new({0, 3}, 8, 4, outline: "O")
      assert {:ok, changes} = Operation.process(rectangle, canvas)
      assert {:ok, canvas} = Canvas.apply_changes(canvas, changes)
      rectangle = Rectangle.new({5, 5}, 5, 3, outline: "X", fill: "X")
      assert {:ok, changes} = Operation.process(rectangle, canvas)
      assert {:ok, canvas} = Canvas.apply_changes(canvas, changes)
      flood_fill = FloodFill.new({0, 0}, "-")
      assert {:ok, changes} = Operation.process(flood_fill, canvas)
      assert {:ok, canvas} = Canvas.apply_changes(canvas, changes)

      assert @fixture3 == to_string(canvas)
    end
  end

  describe "process/2" do
    setup do
      %{canvas: Canvas.new(4, 4)}
    end

    test "fills the canvas", %{canvas: canvas} do
      flood_fill = %FloodFill{point: {1, 2}, fill: "A"}

      assert {:ok, %Changes{} = changes} = Operation.process(flood_fill, canvas)
      assert {:ok, canvas} = Canvas.apply_changes(canvas, changes)

      for i <- 0..3, j <- 0..3 do
        assert Canvas.at(canvas, {i, j}) == "A"
      end
    end

    test "doesn't fill anything if the starting color matches", %{canvas: canvas} do
      point = %Point{point: {0, 0}, character: "A"}
      assert {:ok, %Changes{} = changes} = Operation.process(point, canvas)
      assert {:ok, canvas} = Canvas.apply_changes(canvas, changes)

      flood_fill = %FloodFill{point: {0, 0}, fill: "A"}
      assert {:ok, %Changes{} = changes} = Operation.process(flood_fill, canvas)
      assert changes == %Changes{}
    end

    test "fills single square if surrounded", %{canvas: canvas} do
      rectangle = Rectangle.new({0, 0}, 3, 3, outline: "A")
      assert {:ok, %Changes{} = changes} = Operation.process(rectangle, canvas)
      assert {:ok, canvas} = Canvas.apply_changes(canvas, changes)

      flood_fill = %FloodFill{point: {1, 1}, fill: "B"}
      assert {:ok, %Changes{} = changes} = Operation.process(flood_fill, canvas)
      assert {:ok, canvas} = Canvas.apply_changes(canvas, changes)

      assert to_string(canvas) == """
             AAA\s
             ABA\s
             AAA\s
                \s
             """
    end

    test "fills the outline of a square", %{canvas: canvas} do
      rectangle = Rectangle.new({0, 0}, 3, 3, outline: "A")
      assert {:ok, %Changes{} = changes} = Operation.process(rectangle, canvas)
      assert {:ok, canvas} = Canvas.apply_changes(canvas, changes)

      flood_fill = %FloodFill{point: {2, 2}, fill: "B"}
      assert {:ok, %Changes{} = changes} = Operation.process(flood_fill, canvas)
      assert {:ok, canvas} = Canvas.apply_changes(canvas, changes)

      assert to_string(canvas) == """
             BBB\s
             B B\s
             BBB\s
                \s
             """
    end

    test "returns error if the params are incorrect", %{canvas: canvas} do
      flood_fill = %FloodFill{point: {4, 4}, fill: "A"}
      assert {:error, :out_of_bounds} = Operation.process(flood_fill, canvas)
    end
  end

  describe "validate/2" do
    setup do
      %{canvas: Canvas.new(4, 4)}
    end

    test "validates the starting point is within canvas", %{canvas: canvas} do
      flood_fill = FloodFill.new({4, 4}, "A")
      assert {:error, :out_of_bounds} == FloodFill.validate(canvas, flood_fill)
    end

    test "validates the character is provided", %{canvas: canvas} do
      flood_fill = FloodFill.new({0, 0}, nil)
      assert {:error, :missing_character} == FloodFill.validate(canvas, flood_fill)
    end

    test "passes validation", %{canvas: canvas} do
      flood_fill = FloodFill.new({0, 0}, "A")
      assert :ok == FloodFill.validate(canvas, flood_fill)
    end
  end
end
