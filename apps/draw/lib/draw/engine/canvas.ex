defmodule Draw.Engine.Canvas do
  @moduledoc """
  Canvas structure to keep all the canvas data
  """

  alias Draw.Engine.Canvas

  @type t :: %Canvas{}

  @enforce_keys [:width, :height, :fields]
  defstruct [:width, :height, :fields]

  @doc """
  Creates new Canvas structure. Prefills the canvas with a given character

  # Examples

  iex> Canvas.new(1, 1, "X")
  %Canvas{width: 1, height: 1, fields: %{{0, 0} => "X"}}

  iex> Canvas.new(2, 3) |> Map.get(:fields) |> Map.keys()
  [{0, 0}, {0, 1}, {0, 2}, {1, 0}, {1, 1}, {1, 2}]
  """
  @spec new(width :: integer(), height :: integer(), fill_character :: String.t()) :: t()
  def new(width \\ 32, height \\ 12, fill_character \\ " ") when width > 0 and height > 0 do
    fields =
      for x <- 0..(width - 1), y <- 0..(height - 1), into: %{} do
        {{x, y}, fill_character}
      end

    %Canvas{width: width, height: height, fields: fields}
  end
end
