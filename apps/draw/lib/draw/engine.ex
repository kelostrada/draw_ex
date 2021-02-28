defmodule Draw.Engine do
  @moduledoc """
  Canvas Engine - uses Operations to work on Canvas
  """
  alias Draw.Engine.Canvas
  alias Draw.Engine.Canvas.Loader
  alias Draw.Engine.Canvas.Operation
  alias Draw.Persistence

  require Logger

  @type point :: {width :: pos_integer(), height :: pos_integer()}
  @type ascii :: <<_::8>>

  @doc """
  Prepare a new canvas with given size.
  """
  @spec new_canvas(size :: point() | nil) :: Canvas.t()
  def new_canvas(size \\ nil)

  def new_canvas(nil) do
    Canvas.new()
  end

  def new_canvas({width, height}) do
    Canvas.new(width, height)
  end

  @doc """
  Load canvas from database schema
  """
  @spec load_canvas(Persistence.Canvas.t()) :: {:ok, Canvas.t()} | {:error, :wrong_format}
  def load_canvas(db_canvas) do
    Loader.load(db_canvas.width, db_canvas.height, db_canvas.fields)
  end

  @doc """
  Apply operation on canvas.

  NOTE: In the future this might add history and do other things to the canvas.
  For now it just modifies fields.
  """
  @spec apply_operation(Canvas.t(), Operation.t()) :: {:ok, Canvas.t()} | {:error, atom()}
  def apply_operation(%Canvas{} = canvas, operation) do
    case Operation.process(operation, canvas) do
      {:ok, changes} ->
        Canvas.apply_changes(canvas, changes)

      {:error, error} ->
        Logger.error("Illegal operation #{inspect(operation)} #{inspect(error)}")
        {:error, error}
    end
  end
end
