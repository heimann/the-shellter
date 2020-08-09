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
         container: container.name
       )}
    else
      {:ok,
       assign(socket,
         user: user,
         client: nil,
         connected_users: connected_users,
         container: container.name
       )}
    end
  end
end
