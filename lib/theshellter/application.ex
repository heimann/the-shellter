defmodule Theshellter.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Theshellter.Repo,
      # Start the Telemetry supervisor
      TheshellterWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Theshellter.PubSub},
      # Start the Endpoint (http/https)
      TheshellterWeb.Endpoint,
      # Start a worker by calling: Theshellter.Worker.start_link(arg)
      # {Theshellter.Worker, arg}
      Theshellter.WebsocketClient
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Theshellter.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TheshellterWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
