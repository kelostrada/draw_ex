defmodule Draw.Server do
  @moduledoc """
  Draw server to keep the canvas state in memory and handle the requests
  synchronously.
  """
  use GenServer

  alias Draw.Engine
  alias Draw.Engine.Canvas.Operation.FloodFill
  alias Draw.Engine.Canvas.Operation.Point
  alias Draw.Engine.Canvas.Operation.Rectangle
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

  def draw_rectangle(canvas_id, point, width, height, fill, outline) do
    canvas_id
    |> server_name()
    |> GenServer.call({:draw_rectangle, point, width, height, fill, outline})
  end

  def flood_fill(canvas_id, point, fill) do
    canvas_id
    |> server_name()
    |> GenServer.call({:flood_fill, point, fill})
  end

  @impl true
  def handle_call(:get_canvas, _from, state) do
    {:reply, state.canvas, state}
  end

  @impl true
  def handle_call({:draw_point, point, character}, _from, state) do
    point = %Point{point: point, character: character}
    apply_operation(state, point)
  end

  @impl true
  def handle_call({:draw_rectangle, point, width, height, fill, outline}, _from, state) do
    rectangle = Rectangle.new(point, width, height, fill: fill, outline: outline)
    apply_operation(state, rectangle)
  end

  @impl true
  def handle_call({:flood_fill, point, fill}, _from, state) do
    flood_fill = FloodFill.new(point, fill)
    apply_operation(state, flood_fill)
  end

  defp apply_operation(state, operation) do
    case Engine.apply_operation(state.canvas, operation) do
      {:ok, canvas} ->
        broadcast_canvas(state.canvas_id, canvas)
        {:reply, {:ok, canvas}, persist_canvas(%{state | canvas: canvas})}

      {:error, error} ->
        {:reply, {:error, error}, state}
    end
  end

  def persist_canvas(state) do
    canvas = %Persistence.Canvas{id: state.canvas_id}

    attrs = %{
      width: state.canvas.width,
      height: state.canvas.height,
      fields: to_string(state.canvas)
    }

    # Raise if update fails for some reason
    {:ok, _} = Persistence.update_canvas(canvas, attrs)

    state
  end
end
