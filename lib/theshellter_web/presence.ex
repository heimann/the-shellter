defmodule TheshellterWeb.Presence do
  use Phoenix.Presence,
    otp_app: :theshellter,
    pubsub_server: Theshellter.PubSub
end
