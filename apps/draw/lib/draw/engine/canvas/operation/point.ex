defmodule Draw.Engine.Canvas.Operation.Point do
  @moduledoc """
  The simplest possible operation - will change just one point on the plane
  """
  @enforce_keys [:point, :character]
  defstruct [:point, :character]

  alias Draw.Engine.Canvas
  alias Draw.Engine.Canvas.Changes
  alias Draw.Engine.Canvas.Operation
  alias Draw.Engine.Canvas.Operation.Point

  defimpl Operation do
    def process(%Point{point: point, character: <<character>>}, %Canvas{} = canvas) do
      if Canvas.at(canvas, point) != nil do
        {:ok, %Changes{fields: %{point => character}}}
      else
        {:error, :out_of_bounds}
      end
    end
  end
end
