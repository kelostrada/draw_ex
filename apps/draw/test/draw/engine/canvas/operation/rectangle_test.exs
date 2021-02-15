defmodule Draw.Engine.Canvas.Operation.RectangleTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Draw.Engine.Canvas
  alias Draw.Engine.Canvas.Changes
  alias Draw.Engine.Canvas.Operation
  alias Draw.Engine.Canvas.Operation.Rectangle

  doctest Rectangle

  @fixture1 """
                         \s
                         \s
     @@@@@               \s
     @XXX@  XXXXXXXXXXXXXX
     @@@@@  XOOOOOOOOOOOOX
            XOOOOOOOOOOOOX
            XOOOOOOOOOOOOX
            XOOOOOOOOOOOOX
            XXXXXXXXXXXXXX
                         \s
  """

  @fixture2 """
                .......  \s
                .......  \s
                .......  \s
  OOOOOOOO      .......  \s
  O      O      .......  \s
  O    XXXXX    .......  \s
  OOOOOXXXXX             \s
       XXXXX             \s
                         \s
                         \s
  """

  describe "known fixtures" do
    test "fixture 1" do
      canvas = Canvas.new(24, 10)
      rectangle = Rectangle.new({3, 2}, 5, 3, outline: "@", fill: "X")
      assert {:ok, %Changes{} = changes} = Operation.process(rectangle, canvas)
      assert {:ok, canvas} = Canvas.apply_changes(canvas, changes)
      rectangle = Rectangle.new({10, 3}, 14, 6, outline: "X", fill: "O")
      assert {:ok, %Changes{} = changes} = Operation.process(rectangle, canvas)
      assert {:ok, canvas} = Canvas.apply_changes(canvas, changes)

      assert @fixture1 == to_string(canvas)
    end

    test "fixture 2" do
      canvas = Canvas.new(24, 10)
      rectangle = Rectangle.new({14, 0}, 7, 6, fill: ".")
      assert {:ok, changes} = Operation.process(rectangle, canvas)
      assert {:ok, canvas} = Canvas.apply_changes(canvas, changes)
      rectangle = Rectangle.new({0, 3}, 8, 4, outline: "O")
      assert {:ok, changes} = Operation.process(rectangle, canvas)
      assert {:ok, canvas} = Canvas.apply_changes(canvas, changes)
      rectangle = Rectangle.new({5, 5}, 5, 3, outline: "X", fill: "X")
      assert {:ok, changes} = Operation.process(rectangle, canvas)
      assert {:ok, canvas} = Canvas.apply_changes(canvas, changes)

      assert @fixture2 == to_string(canvas)
    end
  end

  describe "process/2" do
    setup do
      %{canvas: Canvas.new(5, 5)}
    end

    test "draws one point rectangle", %{canvas: canvas} do
      rectangle = Rectangle.new({0, 0}, 1, 1, fill: "A")
      assert {:ok, %Changes{fields: fields}} = Operation.process(rectangle, canvas)
      assert %{{0, 0} => 65} == fields
    end

    test "draws one point rectangle with outline", %{canvas: canvas} do
      rectangle = Rectangle.new({0, 0}, 1, 1, fill: "A", outline: "B")
      assert {:ok, %Changes{fields: fields}} = Operation.process(rectangle, canvas)
      assert %{{0, 0} => 66} == fields
    end

    test "draws a line", %{canvas: canvas} do
      rectangle = Rectangle.new({0, 0}, 3, 1, fill: "A")
      assert {:ok, %Changes{fields: fields}} = Operation.process(rectangle, canvas)
      assert %{{0, 0} => 65, {1, 0} => 65, {2, 0} => 65} == fields

      rectangle = Rectangle.new({0, 0}, 1, 3, fill: "A")
      assert {:ok, %Changes{fields: fields}} = Operation.process(rectangle, canvas)
      assert %{{0, 0} => 65, {0, 1} => 65, {0, 2} => 65} == fields
    end

    test "draws a rectangle", %{canvas: canvas} do
      rectangle = Rectangle.new({0, 0}, 3, 3, fill: "A", outline: "B")
      assert {:ok, %Changes{fields: fields}} = Operation.process(rectangle, canvas)

      assert fields == %{
               {0, 0} => 66,
               {1, 0} => 66,
               {2, 0} => 66,
               {0, 1} => 66,
               {1, 1} => 65,
               {2, 1} => 66,
               {0, 2} => 66,
               {1, 2} => 66,
               {2, 2} => 66
             }
    end

    test "fills the rectangle (without outline)", %{canvas: canvas} do
      rectangle = Rectangle.new({0, 0}, 3, 3, fill: "A")
      assert {:ok, %Changes{fields: fields}} = Operation.process(rectangle, canvas)

      assert fields == %{
               {0, 0} => 65,
               {1, 0} => 65,
               {2, 0} => 65,
               {0, 1} => 65,
               {1, 1} => 65,
               {2, 1} => 65,
               {0, 2} => 65,
               {1, 2} => 65,
               {2, 2} => 65
             }
    end

    test "outlines the rectangle (without fill)", %{canvas: canvas} do
      rectangle = Rectangle.new({0, 0}, 3, 3, outline: "B")
      assert {:ok, %Changes{fields: fields}} = Operation.process(rectangle, canvas)

      assert fields == %{
               {0, 0} => 66,
               {1, 0} => 66,
               {2, 0} => 66,
               {0, 1} => 66,
               {2, 1} => 66,
               {0, 2} => 66,
               {1, 2} => 66,
               {2, 2} => 66
             }
    end

    test "displays error when params are incorrect", %{canvas: canvas} do
      rectangle = Rectangle.new({0, 0}, 1, 1)
      assert {:error, :missing_character} = Operation.process(rectangle, canvas)
    end
  end

  describe "validate/2" do
    setup do
      %{canvas: Canvas.new(5, 5)}
    end

    test "validates width", %{canvas: canvas} do
      rectangle = Rectangle.new({0, 0}, 0, 1, fill: "A")
      assert {:error, :non_positive_width} == Rectangle.validate(canvas, rectangle)
    end

    test "validates height", %{canvas: canvas} do
      rectangle = Rectangle.new({0, 0}, 1, 0, fill: "A")
      assert {:error, :non_positive_height} == Rectangle.validate(canvas, rectangle)
    end

    test "validates the starting point is inside canvas", %{canvas: canvas} do
      rectangle = Rectangle.new({5, 5}, 1, 1, fill: "A")
      assert {:error, :out_of_bounds} == Rectangle.validate(canvas, rectangle)
    end

    test "validates the rectangle fits inside canvas", %{canvas: canvas} do
      rectangle = Rectangle.new({0, 0}, 6, 6, fill: "A")
      assert {:error, :out_of_bounds} == Rectangle.validate(canvas, rectangle)
    end

    test "validates the characters are provided", %{canvas: canvas} do
      rectangle = Rectangle.new({0, 0}, 1, 1)
      assert {:error, :missing_character} == Rectangle.validate(canvas, rectangle)
    end

    test "passes validations", %{canvas: canvas} do
      rectangle = Rectangle.new({0, 0}, 5, 5, fill: "A", outline: "B")
      assert :ok == Rectangle.validate(canvas, rectangle)
    end
  end
end
