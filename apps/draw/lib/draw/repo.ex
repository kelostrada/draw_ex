defmodule Draw.Repo do
  use Ecto.Repo,
    otp_app: :draw,
    adapter: Ecto.Adapters.Postgres
end
