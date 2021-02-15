defprotocol Draw.Engine.Canvas.Operation do
  @moduledoc """
  Drawing operation protocol. Different operations have to implement this protocol to be
  handled by the Engine. The `process/2` function will return `Changes` struct.
  """
  alias Draw.Engine.Canvas
  alias Draw.Engine.Canvas.Changes
  alias Draw.Engine.Canvas.Operation

  @doc """
  Proceed with canvas operation. Will return `%Changes{}` struct that can be later applied to
  the canvas.
  """
  @spec process(Operation.t(), Canvas.t()) :: {:ok, Changes.t()} | {:error, atom()}
  def process(operation, canvas)
end
