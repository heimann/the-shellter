defmodule TheshellterWeb.Authentication.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :theshellter,
    error_handler: TheshellterWeb.Authentication.ErrorHandler,
    module: TheshellterWeb.Authentication

  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
  plug Guardian.Plug.LoadResource, allow_blank: true
end
