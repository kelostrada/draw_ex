defmodule Draw.Engine.Canvas.Changes do
  @moduledoc """
  Structure which stores changes applied to the canvas fields.
  """
  alias Draw.Engine.Canvas.Changes

  @type t :: %Changes{}

  defstruct fields: %{}
end
