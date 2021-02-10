defmodule Draw.Engine do
  @moduledoc """
  Canvas Engine - uses Operations to work on Canvas
  """
  alias Draw.Engine.Canvas
  alias Draw.Engine.Canvas.Operation

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
end
