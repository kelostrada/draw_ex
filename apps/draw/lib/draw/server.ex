defmodule Draw.Server do
  use GenServer

  alias Draw.Engine
  alias Draw.Engine.Canvas.Operation.Point
  alias Phoenix.PubSub

  defmodule State do
    defstruct [:server_id, :canvas]
  end

  defp server_name(server_id), do: :"Draw.Server.#{server_id}"

  def start_link(args) do
    server_id = Keyword.get(args, :server_id)

    if server_id do
      GenServer.start_link(__MODULE__, server_id, name: server_name(server_id))
    else
      {:error, :server_id_required}
    end
  end

  @impl true
  def init(server_id) do
    {:ok,
     %State{
       server_id: server_id,
       canvas: Engine.new_canvas()
     }}
  end

  def get_canvas(server_id) do
    server_id |> server_name() |> GenServer.call(:get_canvas)
  end

  def draw_point(server_id, point, character) do
    server_id |> server_name() |> GenServer.call({:draw_point, point, character})
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
        PubSub.broadcast(Draw.PubSub, "canvas:#{state.server_id}", {:canvas_update, canvas})
        {:reply, {:ok, canvas}, %{state | canvas: canvas}}

      {:error, error} ->
        {:reply, {:error, error}, state}
    end
  end
end
