defmodule TheshellterWeb.TermLive do
  use TheshellterWeb, :live_view

  alias Phoenix.PubSub
  require Logger

  alias Theshellter.Environments

  @impl true
  def handle_info(%{message: message} = params, socket) do
    message = Base.encode64(message)

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

  def handle_event("set_dimensions", %{"height" => height, "width" => width}, socket) do
    HTTPoison.start()

    req_body = URI.encode_query(%{"h" => height, "w" => width})

    HTTPoison.post(
      "http://localhost:2376/containers/#{socket.assigns.container}/resize",
      req_body,
      %{"Content-Type" => "application/x-www-form-urlencoded"}
    )

    {:noreply, socket}
  end

  @impl true
  def mount(params, %{"guardian_default_token" => token} = _session, socket) do
    # Todo figure out wtf that third param is 
    {:ok, user, _} = TheshellterWeb.Authentication.resource_from_token(token)

    {:ok, container} = Theshellter.Environments.get_or_create_container(user.id)

    Logger.debug("user:: #{inspect(user)}")

    Logger.debug("params:: #{inspect(params)}")

    if connected?(socket) do
      PubSub.subscribe(Theshellter.PubSub, container.name)
      {:ok, client} = Theshellter.WebsocketClient.start_link(container.name)
      {:ok, assign(socket, client: client, user: user, container: container.name)}
    else
      {:ok, assign(socket, user: user, client: nil, container: container.name)}
    end
  end
end
