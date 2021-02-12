defmodule Draw.Engine.Canvas.Formatter do
  @moduledoc """
  Formatter for Canvas. Helper functions used for displaying canvas in a text form
  """
  alias Draw.Engine.Canvas

  @doc """
  Returns full string representation of canvas

  # Examples

  iex> Canvas.new(4, 3, "X") |> to_string()
  "XXXX\nXXXX\nXXXX\n"
  """
  @spec to_string(Canvas.t()) :: String.t()
  def to_string(%Canvas{} = canvas) do
    for j <- 0..(canvas.height - 1), i <- 0..canvas.width, into: <<>> do
      if i == canvas.width do
        <<10>>
      else
        Canvas.at(canvas, {i, j})
      end
    end
  end
end
