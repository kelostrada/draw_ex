defmodule Draw.Engine.Canvas.Operation.FloodFill do
  @moduledoc """
  Operation which fills the canvas with given character.

  Struct defines:
  - the **start coordinates** from where to begin the flood fill.
  - a **fill** character.
  """
  alias Draw.Engine
  alias Draw.Engine.Canvas
  alias Draw.Engine.Canvas.Changes
  alias Draw.Engine.Canvas.Operation
  alias Draw.Engine.Canvas.Operation.FloodFill

  @type t :: %FloodFill{}
  @type error :: :out_of_bounds | :missing_character

  @enforce_keys [:point, :fill]
  defstruct [:point, :fill]

  @doc """
  Helper to create new Flood Fill operation.

  # Examples
  iex> FloodFill.new({1, 1}, "X")
  %FloodFill{point: {1, 1}, fill: "X"}
  """
  @spec new(Engine.point(), Engine.ascii()) :: FloodFill.t()
  def new({_, _} = point, fill) do
    %FloodFill{
      point: point,
      fill: fill
    }
  end

  @doc """
  Validates if the flood fill can be drawn on the canvas.
  """
  @spec validate(Canvas.t(), FloodFill.t()) :: :ok | {:error, error()}
  def validate(%Canvas{} = canvas, %FloodFill{point: point} = flood_fill) do
    cond do
      Canvas.at(canvas, point) == nil ->
        {:error, :out_of_bounds}

      is_nil(flood_fill.fill) ->
        {:error, :missing_character}

      true ->
        :ok
    end
  end

  @doc """
  Generates changes to flood fill character on the canvas.
  Should be used after validation.
  """
  @spec draw(Canvas.t(), FloodFill.t()) :: Changes.t()
  def draw(%Canvas{} = canvas, %FloodFill{fill: <<fill>> = fill_color, point: point}) do
    starting_color = Canvas.at(canvas, point)

    if starting_color == fill_color do
      %Changes{}
    else
      fields =
        MapSet.new()
        |> flood_fill(MapSet.new(), point, canvas, starting_color)
        |> elem(0)
        |> MapSet.to_list()
        |> Enum.into(%{}, &{&1, fill})

      %Changes{fields: fields}
    end
  end

  @spec flood_fill(
          MapSet.t(),
          MapSet.t(),
          Engine.point(),
          Canvas.t(),
          Engine.ascii()
        ) ::
          MapSet.t(Engine.point())
  defp flood_fill(points, visited, {x, y} = point, canvas, starting_color) do
    current_color = Canvas.at(canvas, point)

    if MapSet.member?(visited, point) || current_color == nil || current_color != starting_color do
      {points, MapSet.put(visited, point)}
    else
      visited = MapSet.put(visited, point)
      points = MapSet.put(points, point)

      {points, visited} = flood_fill(points, visited, {x + 1, y}, canvas, starting_color)
      {points, visited} = flood_fill(points, visited, {x - 1, y}, canvas, starting_color)
      {points, visited} = flood_fill(points, visited, {x, y + 1}, canvas, starting_color)
      flood_fill(points, visited, {x, y - 1}, canvas, starting_color)
    end
  end

  defimpl Operation do
    def process(%FloodFill{} = operation, %Canvas{} = canvas) do
      case FloodFill.validate(canvas, operation) do
        :ok -> {:ok, FloodFill.draw(canvas, operation)}
        {:error, error} -> {:error, error}
      end
    end
  end
end
