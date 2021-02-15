defmodule Draw.Engine.CanvasTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Draw.Engine.Canvas
  alias Draw.Engine.Canvas.Changes

  doctest Draw.Engine.Canvas

  describe "new/3" do
    property "fields always contain all the keys and correct values" do
      check all width <- positive_integer(),
                height <- positive_integer(),
                character <- string(:ascii, min_length: 1, max_length: 1),
                <<char_code>> = character,
                canvas = Canvas.new(width, height, character),
                expected_fields = for(x <- 0..(width - 1), y <- 0..(height - 1), do: {x, y}) do
        assert width == canvas.width
        assert height == canvas.height
        assert MapSet.new(expected_fields) == canvas.fields |> Map.keys() |> MapSet.new()
        assert Enum.all?(Map.values(canvas.fields), &(&1 == char_code))
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

      assert Canvas.at(canvas, {0, 0}) == "d"
      assert Canvas.at(canvas, {0, 1}) == "e"
      assert Canvas.at(canvas, {1, 0}) == "f"
      assert Canvas.at(canvas, {1, 1}) == "g"
    end

    test "returns nil if the position is out of bounds" do
      canvas = Canvas.new()
      refute Canvas.at(canvas, {-1, -1})
      refute Canvas.at(canvas, {100, 100})
    end
  end

  describe "put/3" do
    test "puts a value on position" do
      canvas = Canvas.new()
      assert {:ok, canvas} = Canvas.put(canvas, {0, 0}, "d")
      assert Canvas.at(canvas, {0, 0}) == "d"
    end

    test "returns error if the point is out of bounds" do
      canvas = Canvas.new()
      assert {:error, :out_of_bounds} = Canvas.put(canvas, {100, 100}, "d")
    end
  end

  describe "apply_changes/2" do
    setup do
      %{canvas: Canvas.new(5, 5, ".")}
    end

    test "applies no changes", %{canvas: canvas} do
      assert {:ok, canvas} == Canvas.apply_changes(canvas, %Changes{})
    end

    test "applies one change", %{canvas: canvas} do
      changes = %Changes{fields: %{{1, 1} => 65}}
      assert {:ok, canvas} = Canvas.apply_changes(canvas, changes)

      expected_canvas = """
      .....
      .A...
      .....
      .....
      .....
      """

      assert expected_canvas == to_string(canvas)
    end

    test "applies multiple changes", %{canvas: canvas} do
      changes = %Changes{fields: %{{1, 1} => 65, {2, 2} => 66, {3, 4} => 67}}
      assert {:ok, canvas} = Canvas.apply_changes(canvas, changes)

      expected_canvas = """
      .....
      .A...
      ..B..
      .....
      ...C.
      """

      assert expected_canvas == to_string(canvas)
    end

    test "returns error if changes out of bounds", %{canvas: canvas} do
      changes = %Changes{fields: %{{5, 5} => 65}}
      assert {:error, :out_of_bounds} == Canvas.apply_changes(canvas, changes)
    end
  end
end
