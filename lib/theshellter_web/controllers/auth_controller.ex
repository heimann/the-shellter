defmodule TheshellterWeb.AuthController do
  use TheshellterWeb, :controller
  plug Ueberauth
  require Logger

  def request(conn, _params) do
  end

  alias Theshellter.Accounts
  alias TheshellterWeb.Authentication

  def callback(%{assigns: %{ueberauth_auth: auth_data}} = conn, _params) do
    Logger.debug("auth_data:: #{inspect(auth_data)}")

    case Accounts.get_or_register(auth_data) do
      {:ok, account} ->
        conn
        |> Authentication.log_in(account)
        |> redirect(to: Routes.live_path(conn, TheshellterWeb.TermLive))

      {:error, _error_changeset} ->
        conn
        |> put_flash(:error, "Authentication failed.")
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  def callback(%{assigns: %{ueberauth_failure: _}} = conn, _params) do
    conn
    |> put_flash(:error, "Authentication failed.")
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
