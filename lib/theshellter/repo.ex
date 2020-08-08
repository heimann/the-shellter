defmodule Theshellter.Repo do
  use Ecto.Repo,
    otp_app: :theshellter,
    adapter: Ecto.Adapters.Postgres
end
