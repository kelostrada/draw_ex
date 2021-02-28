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

  @doc """
  Starts Draw GenServer basing on Canvas ID.
  """
  @spec start_draw_server(Ecto.UUID.t()) :: :ignore | {:error, any} | {:ok, pid} | {:ok, pid, any}
  def start_draw_server(canvas_id) do
    spec = {Draw.Server, canvas_id: canvas_id}

    case DynamicSupervisor.start_child(__MODULE__, spec) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
      error -> error
    end
  end
end
