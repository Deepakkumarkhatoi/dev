defmodule Payx.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PayxWeb.Telemetry,
      Payx.Repo,
      {Ecto.Migrator,
       repos: Application.fetch_env!(:payx, :ecto_repos), skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:payx, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Payx.PubSub},
      # Start a worker by calling: Payx.Worker.start_link(arg)
      # {Payx.Worker, arg},
      # Start to serve requests, typically the last entry
      PayxWeb.Endpoint
    ]

    # See https://elixir.hexdocs.pm/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Payx.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PayxWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp skip_migrations?() do
    # By default, sqlite migrations are run when using a release
    System.get_env("RELEASE_NAME") == nil
  end
end
