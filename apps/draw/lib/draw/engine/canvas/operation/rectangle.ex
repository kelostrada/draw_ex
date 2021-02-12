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
  alias Draw.Engine.Canvas.Operation
  alias Draw.Engine.Canvas.Operation.Rectangle

  @type t :: %Rectangle{}
  @type error :: :non_positive_width | :non_positive_height | :out_of_bounds | :missing_character

  defstruct [:point, :width, :height, fill_character: 32, outline_character: 32]

  @doc """
  Helper to create new rectangle

  # Example
  iex> Rectangle.new({1, 2}, 3, 4, "X", "Y")
  %Rectangle{
    point: {1, 2},
    width: 3,
    height: 4,
    fill_character: 89,
    outline_character: 88
  }
  """
  @spec new(Engine.point(), integer(), integer(), String.t(), String.t()) :: Rectangle.t()
  def new(point, width, height, <<outline_character>> = _outline, <<fill_character>> = _fill) do
    %Rectangle{
      point: point,
      width: width,
      height: height,
      fill_character: fill_character,
      outline_character: outline_character
    }
  end

  @doc """
  [INTERNAL] Validate if the rectangle can be drawn on the canvas.
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

      rectangle.fill_character == 32 && rectangle.outline_character == 32 ->
        {:error, :missing_character}

      true ->
        :ok
    end
  end

  @doc """
  [INTERNAL] Draw the rectangle on the canvas. Should only be used after validation
  """
  @spec draw(Canvas.t(), Rectangle.t()) :: {:ok, Canvas.t()} | {:error, error()}
  def draw(%Canvas{} = canvas, %Rectangle{} = rectangle) do
    fields =
      rectangle
      |> generate_changes()
      |> Enum.reduce(canvas.fields, fn {point, character}, fields ->
        %{fields | point => character}
      end)

    %{canvas | fields: fields}
  end

  @spec generate_changes(Rectangle.t()) :: [{{integer(), integer()}, integer()}]
  defp generate_changes(%Rectangle{point: {x, y}} = rectangle) do
    width = rectangle.width
    height = rectangle.height

    for i <- x..(x + width - 1), j <- y..(y + height - 1) do
      if i == x || j == y || i == x + width - 1 || j == y + height - 1 do
        {{i, j}, rectangle.outline_character}
      else
        {{i, j}, rectangle.fill_character}
      end
    end
  end

  defimpl Operation do
    def process(%Rectangle{} = operation, %Canvas{} = canvas) do
      case Rectangle.validate(canvas, operation) do
        :ok -> {:ok, Rectangle.draw(canvas, operation)}
        {:error, error} -> {:error, error}
      end
    end
  end
end
