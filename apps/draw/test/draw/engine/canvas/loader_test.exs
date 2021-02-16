defmodule Draw.Engine.Canvas.LoaderTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Draw.Engine.Canvas
  alias Draw.Engine.Canvas.Loader
  doctest Loader

  describe "load/3" do
    test "load 1x1 canvas" do
      canvas_string = "A"
      assert {:ok, canvas} = Loader.load(1, 1, canvas_string)
      assert %Canvas{width: 1, height: 1, fields: %{{0, 0} => 65}}
    end

    test "load 2x2 canvas" do
      canvas_string = "AB\nCD"
      assert {:ok, canvas} = Loader.load(2, 2, canvas_string)

      assert %Canvas{
        width: 2,
        height: 2,
        fields: %{{0, 0} => 65, {1, 0} => 66, {0, 1} => 67, {1, 1} => 68}
      }
    end

    property "to_string/1 matches load/3" do
      check all width <- positive_integer(),
                height <- positive_integer(),
                character <- string(:ascii, min_length: 1, max_length: 1),
                canvas = Canvas.new(width, height, character),
                canvas_string = to_string(canvas) do
        assert {:ok, canvas} == Loader.load(width, height, canvas_string)
      end
    end

    test "returns wrong format error if the number of columns doesn't match" do
      canvas_string = "ABCD\nEFGH"
      assert {:error, :wrong_format} = Loader.load(3, 2, canvas_string)

      canvas_string = "AAAA"
      assert {:error, :wrong_format} = Loader.load(5, 1, canvas_string)

      canvas_string = "AAAA\nCCC"
      assert {:error, :wrong_format} = Loader.load(4, 1, canvas_string)
    end

    test "returns wrong format error if the number of rows doesn't match" do
      canvas_string = "A\nA\nA"
      assert {:error, :wrong_format} = Loader.load(1, 2, canvas_string)
    end
  end
end
