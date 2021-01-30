# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

# Configure Mix tasks and generators
config :draw,
  ecto_repos: [Draw.Repo]

config :draw_web,
  ecto_repos: [Draw.Repo],
  generators: [context_app: :draw, binary_id: true]

# Configures the endpoint
config :draw_web, DrawWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "DNBZXk8W13gV1dPNL2uAL2K4GKW/LIz2PZwXLizIAZFz2QkuWQOM0pqsGcFOHhf6",
  render_errors: [view: DrawWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Draw.PubSub,
  live_view: [signing_salt: "Rt4Djb1q"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
