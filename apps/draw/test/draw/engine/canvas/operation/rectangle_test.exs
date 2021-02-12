defmodule Draw.Engine.Canvas.Operation.RectangleTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Draw.Engine.Canvas
  alias Draw.Engine.Canvas.Operation
  alias Draw.Engine.Canvas.Operation.Rectangle

  @fixture1 "" <>
  "                        \n" <>
  "                        \n" <>
  "   @@@@@                \n" <>
  "   @XXX@  XXXXXXXXXXXXXX\n" <>
  "   @@@@@  XOOOOOOOOOOOOX\n" <>
  "          XOOOOOOOOOOOOX\n" <>
  "          XOOOOOOOOOOOOX\n" <>
  "          XOOOOOOOOOOOOX\n" <>
  "          XXXXXXXXXXXXXX\n" <>
  "                        \n"

  @fixture2 "" <>
  "              .......   \n" <>
  "              .......   \n" <>
  "              .......   \n" <>
  "OOOOOOOO      .......   \n" <>
  "O      O      .......   \n" <>
  "O    XXXXX    .......   \n" <>
  "OOOOOXXXXX              \n" <>
  "     XXXXX              \n"

  describe "process/2" do
    test "fixture 1" do
      canvas = Canvas.new(24, 10)
      rectangle = Rectangle.new({3, 2}, 5, 3, "@", "X")
      assert {:ok, canvas} = Operation.process(rectangle, canvas)
      rectangle = Rectangle.new({10, 3}, 14, 6, "X", "O")
      assert {:ok, canvas} = Operation.process(rectangle, canvas)

      assert @fixture1 == to_string(canvas)
    end

    test "fixture 2" do
      canvas = Canvas.new(24, 10)
      rectangle = Rectangle.new({14, 0}, 7, 6, " ", ".")
      assert {:ok, canvas} = Operation.process(rectangle, canvas)
      rectangle = Rectangle.new({0, 3}, 8, 4, "O", " ")
      assert {:ok, canvas} = Operation.process(rectangle, canvas)
      rectangle = Rectangle.new({5, 5}, 5, 3, "X", "X")
      assert {:ok, canvas} = Operation.process(rectangle, canvas)

      assert @fixture2 == to_string(canvas)
    end
  end
end
