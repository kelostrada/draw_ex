defprotocol Draw.Engine.Canvas.Operation do
  @moduledoc """
  Drawing operation protocol. Different operations have to implement this protocol to be
  handled by the Engine.
  """
  alias Draw.Engine.Canvas
  alias Draw.Engine.Canvas.Operation

  @doc """
  Proceed with canvas operation
  """
  @spec process(Operation.t(), Canvas.t()) :: {:ok, Canvas.t()} | {:error, atom()}
  def process(operation, canvas)
end
