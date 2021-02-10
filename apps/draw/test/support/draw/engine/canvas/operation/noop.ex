defmodule Draw.Engine.Canvas.Operation.Noop do
  alias Draw.Engine.Canvas.Operation
  defstruct []

  defimpl Operation do
    def process(_noop, canvas), do: {:ok, canvas}
  end
end
