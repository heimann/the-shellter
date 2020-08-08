defmodule TheshellterWeb.TermLive do
  use TheshellterWeb, :live_view
  alias Phoenix.PubSub
  require Logger

  @impl true
  def handle_info(%{message: message} = params, socket) do
    Logger.info("message: #{message}")

    {:noreply,
     socket
     |> Phoenix.LiveView.push_event("message", %{message: message})}
  end

  @impl true
  def handle_event("logout", _params, socket) do
    {:noreply,
     socket
     |> redirect(
       to: Routes.session_path(socket, :delete),
       method: :delete
     )}
  end

  def handle_event("send_keystroke", params, socket) do
    Logger.debug("params:: #{inspect(params)}")
    Theshellter.WebsocketClient.send(socket.assigns.client, params)
    {:noreply, socket}
  end

  @impl true
  def mount(_params, _session, socket) do
    Logger.info("Mounting")

    uuid = Ecto.UUID.generate()

    if connected?(socket) do
      PubSub.subscribe(Theshellter.PubSub, uuid)
      {:ok, client} = Theshellter.WebsocketClient.start_link(uuid)
      {:ok, assign(socket, client: client)}
    else
      {:ok, assign(socket, client: nil)}
    end
  end
end
