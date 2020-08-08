defmodule TheshellterWeb.TermLive do
  use TheshellterWeb, :live_view

  @impl true
  def handle_event("logout", _params, socket) do
    {:noreply,
     socket
     |> redirect(
       to: Routes.session_path(socket, :delete),
       method: :delete
     )}
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, query: "", results: %{})}
  end
end
