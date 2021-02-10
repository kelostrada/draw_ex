defmodule Draw.Engine do
  @moduledoc """
  Canvas Engine - uses Operations to work on Canvas
  """
  alias Draw.Engine.Canvas
  alias Draw.Engine.Canvas.Operation

  require Logger

  @type point :: {width :: pos_integer(), height :: pos_integer()}

  @doc """
  Prepare a new canvas with given size.
  """
  @spec new_canvas(size :: point()) :: Canvas.t()
  def new_canvas(size \\ nil)

  def new_canvas(nil) do
    Canvas.new()
  end

  def new_canvas({width, height}) do
    Canvas.new(width, height)
  end

  @doc """
  Apply operation on canvas.

  NOTE: In the future this might add history and do other things to the canvas.
  For now it just modifies fields.
  """
  @spec apply_operation(Canvas.t(), Operation.t()) :: {:ok, Canvas.t()} | {:error, atom()}
  def apply_operation(%Canvas{} = canvas, %{} = operation) do
    case Operation.process(operation, canvas) do
      {:ok, canvas} ->
        {:ok, canvas}

      {:error, error} ->
        Logger.error("Illegal operation #{inspect(operation)} #{inspect(error)}")
        {:error, error}
    end
  end
end
