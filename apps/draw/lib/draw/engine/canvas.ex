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
  Returns a character that is at a given position. If the point is out of bounds
  it will return nil.
  """
  @spec at(Canvas.t(), Engine.point()) :: Engine.ascii() | nil
  def at(%Canvas{} = canvas, {_, _} = point) do
    Map.get(canvas.fields, point)
  end

  @doc """
  Updates a character at a given position on the field. If the point is out of
  bounds it will return an error tuple `{:error, :out_of_bounds}`.
  """
  @spec put(Canvas.t(), Engine.point(), Engine.ascii()) ::
          {:ok, Canvas.t()} | {:error, :out_of_bounds}
  def put(%Canvas{} = canvas, {_, _} = point, character) do
    if at(canvas, point) != nil do
      {:ok, %{canvas | fields: %{canvas.fields | point => character}}}
    else
      {:error, :out_of_bounds}
    end
  end
end
