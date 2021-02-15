defmodule Draw.Engine.Canvas.Operation.Noop do
  alias Draw.Engine.Canvas.Changes
  alias Draw.Engine.Canvas.Operation
  defstruct []

  defimpl Operation do
    def process(_noop, _canvas), do: {:ok, %Changes{}}
  end
end
