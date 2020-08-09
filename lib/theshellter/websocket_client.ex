defmodule Theshellter.WebsocketClient do
  use WebSockex
  require Logger
  alias Phoenix.PubSub

  def start_link(state) do
    WebSockex.start_link(
      "ws://localhost:2376/containers/#{state}/attach/ws?stream=1",
      __MODULE__,
      state
    )
  end

  def handle_connect(_conn, state) do
    Logger.info("Connected!")
    {:ok, state}
  end

  def send(client, message) do
    Logger.info("Sending message: #{message}")
    WebSockex.send_frame(client, {:text, IO.chardata_to_string(message)})
  end

  def handle_frame({:binary, _msg}, []) do
    {:ok, []}
  end

  def handle_frame({:binary, msg}, state) do
    Logger.info("state is not empty")

    case :ets.lookup(:listeners, state) do
      [] ->
        :ets.insert(:listeners, {state, self()})
        Phoenix.PubSub.broadcast(Theshellter.PubSub, state, %{message: msg})
        {:ok, state}

      [{_id, pid}] ->
        if pid == self() do
          Phoenix.PubSub.broadcast(Theshellter.PubSub, state, %{message: msg})
        end

        {:ok, state}
    end
  end

  def handle_disconnect(%{reason: {:local, reason}}, state) do
    Logger.info("Local close with reason: #{inspect(reason)}")
    {:ok, state}
  end

  def terminate(reason, state) do
    IO.puts("\nSocket Terminating:\n#{inspect(reason)}\n\n#{inspect(state)}\n")
  end
end
