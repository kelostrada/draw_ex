defmodule Draw.Engine.Canvas.Operation.Failop do
  @moduledoc false
  alias Draw.Engine.Canvas.Operation

  defstruct []

  defimpl Operation do
    def process(_noop, _canvas), do: {:error, :failed}
  end
end
