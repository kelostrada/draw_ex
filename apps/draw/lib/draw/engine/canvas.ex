defmodule Draw.Engine.Canvas do
  @moduledoc """
  Canvas structure to keep all the canvas data
  """

  alias Draw.Engine
  alias Draw.Engine.Canvas

  @type t :: %Canvas{}

  @enforce_keys [:width, :height, :fields]
  defstruct [:width, :height, :fields]

  @doc """
  Creates new Canvas structure. Prefills the canvas with a given character

  # Examples

  iex> Canvas.new(1, 1, 32)
  %Canvas{width: 1, height: 1, fields: %{{0, 0} => 32}}

  iex> Canvas.new(2, 3) |> Map.get(:fields) |> Map.keys()
  [{0, 0}, {0, 1}, {0, 2}, {1, 0}, {1, 1}, {1, 2}]
  """
  @spec new(width :: integer(), height :: integer(), fill_character :: Engine.ascii()) :: t()
  def new(width \\ 32, height \\ 12, fill_character \\ 32) when width > 0 and height > 0 do
    fields =
      for x <- 0..(width - 1), y <- 0..(height - 1), into: %{} do
        {{x, y}, fill_character}
      end

    %Canvas{width: width, height: height, fields: fields}
  end

  @doc """
  Returns a character that is at a given position
  """
  @spec at(Canvas.t(), Engine.point()) :: Engine.ascii() | nil
  def at(canvas, point) do
    Map.get(canvas.fields, point)
  end
end
