defmodule Draw.Server do
  @moduledoc """
  Draw server to keep the canvas state in memory and handle the requests
  synchronously.
  """
  use GenServer

  alias Draw.Engine
  alias Draw.Engine.Canvas.Operation.Point
  alias Draw.Persistence
  alias Phoenix.PubSub

  defmodule State do
    @moduledoc false
    defstruct [:canvas_id, :canvas]
  end

  defp server_name(canvas_id), do: :"Draw.Server.#{canvas_id}"

  defp broadcast_canvas(canvas_id, canvas) do
    PubSub.broadcast(Draw.PubSub, "canvas:#{canvas_id}", {:canvas_update, canvas})
  end

  def start_link(args) do
    canvas_id = Keyword.get(args, :canvas_id)

    if canvas_id do
      GenServer.start_link(__MODULE__, canvas_id, name: server_name(canvas_id))
    else
      {:error, :missing_canvas_id}
    end
  end

  @impl true
  def init(canvas_id) do
    with %{} = db_canvas <- Persistence.get_canvas(canvas_id),
         {:ok, canvas} <- Engine.load_canvas(db_canvas) do
      broadcast_canvas(canvas_id, canvas)

      {:ok, %State{canvas_id: canvas_id, canvas: canvas}}
    else
      nil ->
        {:stop, :not_found}

      {:error, error} ->
        {:stop, error}
    end
  end

  def get_canvas(canvas_id) do
    canvas_id |> server_name() |> GenServer.call(:get_canvas)
  end

  def draw_point(canvas_id, point, character) do
    canvas_id |> server_name() |> GenServer.call({:draw_point, point, character})
  end

  @impl true
  def handle_call(:get_canvas, _from, state) do
    {:reply, state.canvas, state}
  end

  @impl true
  def handle_call({:draw_point, point, character}, _from, state) do
    point = %Point{point: point, character: character}

    case Engine.apply_operation(state.canvas, point) do
      {:ok, canvas} ->
        PubSub.broadcast(Draw.PubSub, "canvas:#{state.canvas_id}", {:canvas_update, canvas})
        {:reply, {:ok, canvas}, %{state | canvas: canvas}}

      {:error, error} ->
        {:reply, {:error, error}, state}
    end
  end
end
