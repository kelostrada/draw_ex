defmodule DrawWeb.PageLive do
  @moduledoc false
  use DrawWeb, :live_view

  alias Draw.Engine.Canvas
  alias Phoenix.PubSub

  @impl true
  def mount(params, _session, socket) do
    canvas_id = Map.get(params, "canvas_id")
    PubSub.subscribe(Draw.PubSub, "canvas:#{canvas_id}")
    {:ok, canvas_id} = Draw.init_canvas(canvas_id)
    canvas = Draw.Server.get_canvas(canvas_id)
    {:ok, socket |> assign(canvas: canvas) |> assign(canvas_id: canvas_id)}
  end

  @impl true
  def handle_info({:canvas_update, canvas}, socket) do
    {:noreply, assign(socket, canvas: canvas)}
  end

  @impl true
  def handle_event("set_options", _opts, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("draw_point", %{"x" => x, "y" => y}, socket) do
    {x, _} = Integer.parse(x)
    {y, _} = Integer.parse(y)

    Draw.Server.draw_point(socket.assigns.canvas_id, {x, y}, "X")

    {:noreply, socket}
  end
end
