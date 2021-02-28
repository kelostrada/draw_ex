defmodule Draw do
  @moduledoc """
  `Draw` is a simple app used to "draw" on canvas with ASCII letters
  using different operations (like rectangle or flood fill).
  """

  alias Draw.Engine
  alias Draw.Persistence

  @type error :: :not_found | :wrong_format

  @doc """
  Initialize canvas. Creates canvas in database, or loads it from database if
  the UUID is provided. Will start up a genserver that holds the canvas data in memory.
  """
  @spec init_canvas(id :: Ecto.UUID.t() | nil) ::
          {:ok, {pid(), Ecto.UUID.t(), Engine.Canvas.t()}}
          | {:error, Ecto.Changeset.t()}
          | {:error, error()}
  def init_canvas(id \\ nil)

  def init_canvas(nil) do
    canvas = Engine.new_canvas()

    attrs = %{
      width: canvas.width,
      height: canvas.height,
      fields: to_string(canvas)
    }

    case Persistence.create_canvas(attrs) do
      {:ok, db_canvas} ->
        {:ok, {self(), db_canvas.id, canvas}}

      {:error, error} ->
        {:error, error}
    end
  end

  def init_canvas(id) do
    with {:get_canvas, %Persistence.Canvas{} = db_canvas} <-
           {:get_canvas, Persistence.get_canvas(id)},
         {:ok, canvas} <-
           Engine.load_canvas({db_canvas.width, db_canvas.height}, db_canvas.fields) do
      {:ok, {self(), db_canvas.id, canvas}}
    else
      {:get_canvas, nil} -> {:error, :not_found}
      {:error, error} -> {:error, error}
    end
  end
end
