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
  def handle_info({:joined, nickname}, socket) do
    {:noreply, assign(socket, observers: [nickname | socket.assigns.observers])}
  end

  @impl true
  def handle_info({:left, nickname}, socket) do
    {:noreply,
     assign(socket,
       observers:
         socket.assigns.observers
         |> Enum.reject(&(&1 == nickname))
     )}
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
        if pid == socket.assigns.client or !Process.alive?(pid) do
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
        %{"target" => target, "nickname" => nickname},
        %{assigns: %{container: container}} = socket
      ) do
    PubSub.broadcast!(
      Theshellter.PubSub,
      container,
      {:left, socket.assigns.user.nickname}
    )

    PubSub.unsubscribe(Theshellter.PubSub, container)

    case :ets.lookup(:listeners, socket.assigns.container) do
      [{_id, pid}] ->
        if pid == socket.assigns.client do
          Logger.debug("Listening client should be closed.")
          :ets.delete(:listeners, socket.assigns.container)
        end

      _ ->
        Logger.debug("No listening client")
    end

    PubSub.subscribe(Theshellter.PubSub, target)
    {:ok, client} = Theshellter.WebsocketClient.start_link(target)

    Logger.debug("#{socket.assigns.user.nickname} connecting to #{nickname}")

    PubSub.broadcast!(Theshellter.PubSub, target, {:joined, socket.assigns.user.nickname})

    {:noreply,
     socket
     |> assign(container: target, client: client, container_session: nickname)}
  end

  @impl true
  def handle_event(
        "disconnect_from_peer",
        _params,
        %{assigns: %{container: current_container, user: user}} = socket
      ) do
    PubSub.broadcast!(
      Theshellter.PubSub,
      current_container,
      {:left, socket.assigns.user.nickname}
    )

    PubSub.unsubscribe(Theshellter.PubSub, current_container)

    case :ets.lookup(:listeners, socket.assigns.container) do
      [{_id, pid}] ->
        if pid == socket.assigns.client do
          Logger.debug("Listening client should be closed.")
          :ets.delete(:listeners, socket.assigns.container)
        else
        end

      _ ->
        Logger.debug("No listening client")
    end

    {:ok, container} = Theshellter.Environments.get_or_create_container(user.id)

    PubSub.subscribe(Theshellter.PubSub, container.name)
    {:ok, client} = Theshellter.WebsocketClient.start_link(container.name)

    {:noreply,
     socket
     |> assign(container: container.name, client: client, container_session: user.nickname)}
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
          connected_to: user.nickname,
          container: container.name
        }
      )

      {:ok,
       assign(socket,
         client: client,
         connected_users: connected_users,
         user: user,
         container_session: user.nickname,
         observers: [],
         waving_user: nil,
         container: container.name
       )}
    else
      {:ok,
       assign(socket,
         user: user,
         client: nil,
         waving_user: nil,
         container_session: user.nickname,
         observers: [],
         connected_users: connected_users,
         container: container.name
       )}
    end
  end
end
