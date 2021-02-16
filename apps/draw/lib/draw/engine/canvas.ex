defmodule Draw.Engine.Canvas do
  @moduledoc """
  Canvas structure to keep all the canvas data
  """

  alias Draw.Engine
  alias Draw.Engine.Canvas
  alias Draw.Engine.Canvas.Changes

  @type t :: %Canvas{}

  @enforce_keys [:width, :height, :fields]
  defstruct [:width, :height, :fields]

  defimpl String.Chars do
    def to_string(%Canvas{} = canvas) do
      Canvas.Formatter.to_string(canvas)
    end
  end

  defimpl Inspect do
    def inspect(%Canvas{} = canvas, _opts) do
      "#Canvas<#{canvas.width}x#{canvas.height}>\n" <>
        "#{String.duplicate("=", canvas.width)}\n" <>
        "#{canvas}" <>
        "#{String.duplicate("=", canvas.width)}\n"
    end
  end

  @doc """
  Creates new Canvas structure. Prefills the canvas with a given character

  # Examples

  iex> Canvas.new(1, 1, " ")
  %Canvas{width: 1, height: 1, fields: %{{0, 0} => 32}}

  iex> Canvas.new(2, 3) |> Map.get(:fields) |> Map.keys()
  [{0, 0}, {0, 1}, {0, 2}, {1, 0}, {1, 1}, {1, 2}]
  """
  @spec new(width :: integer(), height :: integer(), fill_character :: String.t()) :: t()
  def new(width \\ 32, height \\ 12, <<fill>> = _fill_character \\ " ")
      when width > 0 and height > 0 do
    fields =
      for x <- 0..(width - 1), y <- 0..(height - 1), into: %{} do
        {{x, y}, fill}
      end

    %Canvas{width: width, height: height, fields: fields}
  end

  @doc """
  Returns a character that is at a given position. If the point is out of bounds
  it will return nil.
  """
  @spec at(Canvas.t(), Engine.point()) :: Engine.ascii() | nil
  def at(%Canvas{} = canvas, {_, _} = point) do
    character = Map.get(canvas.fields, point)
    if character, do: <<character>>
  end

  @doc """
  Updates a character at a given position on the field. If the point is out of
  bounds it will return an error tuple `{:error, :out_of_bounds}`.
  """
  @spec put(Canvas.t(), Engine.point(), Engine.ascii()) ::
          {:ok, Canvas.t()} | {:error, :out_of_bounds}
  def put(%Canvas{} = canvas, {_, _} = point, <<char_code>> = _character) do
    if at(canvas, point) != nil do
      {:ok, %{canvas | fields: %{canvas.fields | point => char_code}}}
    else
      {:error, :out_of_bounds}
    end
  end

  @doc """
  Apply changes to the Canvas fields. Will check if the changes go out of bounds and return
  error tuple `{:error, :out_of_bounds}` in such a case.
  """
  @spec apply_changes(Canvas.t(), Changes.t()) :: {:ok, Canvas.t()} | {:error, :out_of_bounds}
  def apply_changes(%Canvas{} = canvas, %Changes{} = changes) do
    Enum.reduce_while(changes.fields, {:ok, canvas}, fn {point, character}, {:ok, canvas} ->
      case put(canvas, point, <<character>>) do
        {:ok, canvas} -> {:cont, {:ok, canvas}}
        {:error, error} -> {:halt, {:error, error}}
      end
    end)
  end
end
