defmodule Draw do
  @moduledoc """
  `Draw` is a simple app used to "draw" on canvas with ASCII letters
  using different operations (like rectangle or flood fill).
  """

  alias Draw.Engine
  alias Draw.Persistence
  alias Draw.ServerSupervisor

  @type error :: :not_found | :wrong_format

  @doc """
  Initialize canvas. Creates canvas in database, or loads it from database if
  the UUID is provided. Will start up a genserver that holds the canvas data in memory.
  """
  @spec init_canvas(canvas_id :: Ecto.UUID.t() | nil) ::
          {:ok, canvas_id :: Ecto.UUID.t()}
          | {:error, error()}
  def init_canvas(canvas_id \\ nil)

  def init_canvas(nil) do
    case Persistence.create_empty_canvas() do
      {:ok, db_canvas} ->
        init_canvas(db_canvas.id)

      {:error, error} ->
        {:error, error}
    end
  end

  def init_canvas(canvas_id) do
    case ServerSupervisor.start_draw_server(canvas_id) do
      {:ok, _pid} -> {:ok, canvas_id}
      {:error, error} -> {:error, error}
    end
  end
end
