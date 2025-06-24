defmodule PhoenixRaffley.Repo do
  use Ecto.Repo,
    otp_app: :phoenix_raffley,
    adapter: Ecto.Adapters.Postgres
end
