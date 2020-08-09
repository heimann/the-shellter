defmodule TheshellterWeb.TermLive do
  use TheshellterWeb, :live_view

  alias Phoenix.PubSub
  require Logger

  @impl true
  def handle_info(%{message: message} = _params, socket) do
    message = Base.encode64(message)

    {:noreply,
     socket
     |> Phoenix.LiveView.push_event("message", %{message: message})}
  end

  def handle_info("clear_flash", socket) do
    {:noreply, clear_flash(socket)}
  end

  @impl true
  def handle_info(%{waves: user}, socket) do
    Process.send_after(self(), "clear_flash", 3000)
    Logger.debug("User waves!")

    {:noreply,
     socket
     |> put_flash(:info, "#{user} 👋")}
  end

  @impl true
  def handle_info(
        %{event: "presence_diff", payload: %{joins: joins, leaves: leaves}},
        socket
      ) do
    connected_users =
      TheshellterWeb.Presence.list("term")
      |> Enum.map(fn {_user_id, data} ->
        data[:metas]
        |> List.first()
      end)

    Logger.debug("joins:: #{inspect(joins)}")
    Logger.debug("leaves:: #{inspect(leaves)}")

    {:noreply, assign(socket, connected_users: connected_users)}
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

  @impl true
  def handle_event(
        "ping_user",
        %{"target" => target} = _params,
        %{assigns: %{user: user}} = socket
      ) do
    Phoenix.PubSub.broadcast(Theshellter.PubSub, target, %{waves: user.nickname})
    {:noreply, socket}
  end

  @impl true
  def handle_event("unmounted", _params, socket) do
    case :ets.lookup(:listeners, socket.assigns.container) do
      [{_id, pid}] ->
        if pid == socket.assigns.client do
          Logger.debug("Listening client should be closed.")
          :ets.delete(:listeners, socket.assigns.container)
          {:noreply, socket}
        else
          {:noreply, socket}
        end

      [] ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event(
        "switch_term",
        %{"target" => target},
        %{assigns: %{container: container}} = socket
      ) do
    PubSub.unsubscribe(Theshellter.PubSub, container)

    [{_id, pid}] = :ets.lookup(:listeners, container)

    if pid == socket.assigns.client do
      Logger.debug("Listening client should be closed.")
      :ets.delete(:listeners, socket.assigns.container)
    end

    PubSub.subscribe(Theshellter.PubSub, target)
    {:ok, client} = Theshellter.WebsocketClient.start_link(target)

    {:noreply,
     socket
     |> assign(container: target, client: client)}
  end

  @impl true
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

    connected_users =
      TheshellterWeb.Presence.list("term")
      |> Enum.map(fn {_user_id, data} ->
        data[:metas]
        |> List.first()
      end)

    if connected?(socket) do
      PubSub.subscribe(Theshellter.PubSub, container.name)
      {:ok, client} = Theshellter.WebsocketClient.start_link(container.name)
      Logger.debug("client:: #{inspect(client)}")

      TheshellterWeb.Endpoint.subscribe("term")

      TheshellterWeb.Presence.track(
        self(),
        "term",
        user.id,
        %{
          nickname: user.nickname,
          container: container.name
        }
      )

      {:ok,
       assign(socket,
         client: client,
         connected_users: connected_users,
         user: user,
         waving_user: nil,
         container: container.name
       )}
    else
      {:ok,
       assign(socket,
         user: user,
         client: nil,
         waving_user: nil,
         connected_users: connected_users,
         container: container.name
       )}
    end
  end
end
