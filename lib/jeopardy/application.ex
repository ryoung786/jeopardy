defmodule Jeopardy.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Jeopardy.Repo,
      # Start the Telemetry supervisor
      JeopardyWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Jeopardy.PubSub},
      # Start the Presence tracker
      JeopardyWeb.Presence,
      # Start cachex
      {Cachex, :stats},
      # Start the Endpoint (http/https)
      JeopardyWeb.Endpoint,
      # Start a worker by calling: Jeopardy.Worker.start_link(arg)
      # {Jeopardy.Worker, arg}
      Jeopardy.BIReplication,
      Jeopardy.Cron.CullOldRecords
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Jeopardy.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    JeopardyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
