defmodule PhoenixRaffley.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PhoenixRaffleyWeb.Telemetry,
      PhoenixRaffley.Repo,
      {DNSCluster, query: Application.get_env(:phoenix_raffley, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PhoenixRaffley.PubSub},
      PhoenixRaffleyWeb.Presence,
      # Start the Finch HTTP client for sending emails
      {Finch, name: PhoenixRaffley.Finch},
      # Start a worker by calling: PhoenixRaffley.Worker.start_link(arg)
      # {PhoenixRaffley.Worker, arg},
      # Start to serve requests, typically the last entry
      PhoenixRaffleyWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PhoenixRaffley.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PhoenixRaffleyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
