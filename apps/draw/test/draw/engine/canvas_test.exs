defmodule Draw.Engine.CanvasTest do
  use ExUnit.Case
  use ExUnitProperties
  alias Draw.Engine.Canvas

  doctest Draw.Engine.Canvas

  describe "new/3" do
    property "fields always contain all the keys and correct values" do
      check all width <- positive_integer(),
                height <- positive_integer(),
                character <- string(:ascii, min_length: 1, max_length: 1),
                canvas = Canvas.new(width, height, character),
                expected_fields = for(x <- 0..(width - 1), y <- 0..(height - 1), do: {x, y}) do
        assert width == canvas.width
        assert height == canvas.height
        assert MapSet.new(expected_fields) == canvas.fields |> Map.keys() |> MapSet.new()
        assert Enum.all?(Map.values(canvas.fields), &(&1 == character))
      end
    end
  end
end
