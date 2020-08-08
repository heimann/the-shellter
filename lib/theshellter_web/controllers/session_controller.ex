defmodule TheshellterWeb.SessionController do
  use TheshellterWeb, :controller

  alias TheshellterWeb.Authentication

  def delete(conn, _params) do
    conn
    |> Authentication.log_out()
    |> redirect(to: "/")
  end
end
