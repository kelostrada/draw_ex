defmodule Draw.Engine.CanvasTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Draw.Engine.Canvas

  doctest Draw.Engine.Canvas

  describe "new/3" do
    property "fields always contain all the keys and correct values" do
      check all width <- positive_integer(),
                height <- positive_integer(),
                character <- integer(0..255),
                canvas = Canvas.new(width, height, character),
                expected_fields = for(x <- 0..(width - 1), y <- 0..(height - 1), do: {x, y}) do
        assert width == canvas.width
        assert height == canvas.height
        assert MapSet.new(expected_fields) == canvas.fields |> Map.keys() |> MapSet.new()
        assert Enum.all?(Map.values(canvas.fields), &(&1 == character))
      end
    end
  end

  describe "at/2" do
    test "gets a value on position" do
      canvas = %Canvas{
        width: 2,
        height: 2,
        fields: %{{0, 0} => 100, {0, 1} => 101, {1, 0} => 102, {1, 1} => 103}
      }

      assert Canvas.at(canvas, {0, 0}) == 100
      assert Canvas.at(canvas, {0, 1}) == 101
      assert Canvas.at(canvas, {1, 0}) == 102
      assert Canvas.at(canvas, {1, 1}) == 103
    end

    test "returns nil if the position is out of bounds" do
      canvas = Canvas.new()
      refute Canvas.at(canvas, {-1, -1})
      refute Canvas.at(canvas, {100, 100})
    end
  end

  describe "put/2" do
    test "puts a value on position" do
      canvas = Canvas.new()
      assert {:ok, canvas} = Canvas.put(canvas, {0, 0}, 100)
      assert Canvas.at(canvas, {0, 0}) == 100
    end

    test "returns error if the point is out of bounds" do
      canvas = Canvas.new()
      assert {:error, :out_of_bounds} = Canvas.put(canvas, {100, 100}, 100)
    end
  end
end
