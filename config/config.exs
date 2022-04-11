import Config

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

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.0",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../apps/draw_web/assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
