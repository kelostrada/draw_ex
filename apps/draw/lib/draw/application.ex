defmodule Draw.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Draw.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Draw.PubSub}
      # Start a worker by calling: Draw.Worker.start_link(arg)
      # {Draw.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Draw.Supervisor)
  end
end
