defmodule Draw.Engine.Canvas.Operation.Rectangle do
  @moduledoc """
  Operation which draws rectangle on the plane.

  Struct defines:
  - Coordinates for the **upper-left corner**.
  - **width** and **height**.
  - an optional **fill** character.
  - an optional **outline** character.
  - One of either **fill** or **outline** should always be present.
  """
  alias Draw.Engine
  alias Draw.Engine.Canvas
  alias Draw.Engine.Canvas.Changes
  alias Draw.Engine.Canvas.Operation
  alias Draw.Engine.Canvas.Operation.Rectangle

  @type t :: %Rectangle{}
  @type error :: :non_positive_width | :non_positive_height | :out_of_bounds | :missing_character
  @typep character_type :: {:fill, Engine.ascii()} | {:outline, Engine.ascii()}
  @type opts :: [character_type()]

  @enforce_keys [:point, :width, :height, :fill, :outline]
  defstruct [:point, :width, :height, :fill, :outline]

  @doc """
  Helper to create new rectangle.

  It doesn't run validations as structs can be created manually
  anyway so no point enforcing validations on the creation of
  Rectangle operation.

  # Examples
  iex> Rectangle.new({1, 2}, 3, 4, [fill: "X", outline: "Y"])
  %Rectangle{
    point: {1, 2},
    width: 3,
    height: 4,
    fill: "X",
    outline: "Y"
  }

  iex> Rectangle.new({1, 2}, 3, 4)
  %Rectangle{
    point: {1, 2},
    width: 3,
    height: 4,
    fill: nil,
    outline: nil
  }
  """
  @spec new(Engine.point(), integer(), integer(), opts()) :: Rectangle.t()
  def new(point, width, height, opts \\ []) do
    %Rectangle{
      point: point,
      width: width,
      height: height,
      fill: Keyword.get(opts, :fill),
      outline: Keyword.get(opts, :outline)
    }
  end

  @doc """
  Validates if the rectangle can be drawn on the canvas.
  """
  @spec validate(Canvas.t(), Rectangle.t()) :: :ok | {:error, error()}
  def validate(%Canvas{} = canvas, %Rectangle{point: {x, y} = point} = rectangle) do
    cond do
      rectangle.width <= 0 ->
        {:error, :non_positive_width}

      rectangle.height <= 0 ->
        {:error, :non_positive_height}

      Canvas.at(canvas, point) == nil ->
        {:error, :out_of_bounds}

      Canvas.at(canvas, {x + rectangle.width - 1, y + rectangle.height - 1}) == nil ->
        {:error, :out_of_bounds}

      is_nil(rectangle.fill) && is_nil(rectangle.outline) ->
        {:error, :missing_character}

      true ->
        :ok
    end
  end

  @doc """
  Generates changes to draw the rectangle on the canvas.
  Should be used after validation.
  """
  @spec draw(Rectangle.t()) :: Changes.t()
  def draw(%Rectangle{fill: nil, outline: <<outline>>, point: {x1, y1}} = rectangle) do
    x2 = x1 + rectangle.width - 1
    y2 = y1 + rectangle.height - 1

    fields =
      for i <- x1..x2, j <- y1..y2, i == x1 || i == x2 || j == y1 || j == y2, into: %{} do
        {{i, j}, outline}
      end

    %Changes{fields: fields}
  end

  def draw(%Rectangle{fill: <<fill>>, outline: nil, point: {x1, y1}} = rectangle) do
    x2 = x1 + rectangle.width - 1
    y2 = y1 + rectangle.height - 1

    fields =
      for i <- x1..x2, j <- y1..y2, into: %{} do
        {{i, j}, fill}
      end

    %Changes{fields: fields}
  end

  def draw(%Rectangle{fill: <<fill>>, outline: <<outline>>, point: {x1, y1}} = rectangle) do
    x2 = x1 + rectangle.width - 1
    y2 = y1 + rectangle.height - 1

    fields =
      for i <- x1..x2, j <- y1..y2, into: %{} do
        if i == x1 || i == x2 || j == y1 || j == y2 do
          {{i, j}, outline}
        else
          {{i, j}, fill}
        end
      end

    %Changes{fields: fields}
  end

  defimpl Operation do
    def process(%Rectangle{} = operation, %Canvas{} = canvas) do
      case Rectangle.validate(canvas, operation) do
        :ok -> {:ok, Rectangle.draw(operation)}
        {:error, error} -> {:error, error}
      end
    end
  end
end
