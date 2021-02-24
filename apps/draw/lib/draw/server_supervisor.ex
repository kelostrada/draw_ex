defmodule Draw.ServerSupervisor do
  @moduledoc """
  Dynamic Supervisor for Draw Servers.
  """
  use DynamicSupervisor

  def start_link(args) do
    DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_draw_server(server_id) do
    spec = {Draw.Server, server_id: server_id}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end
end
