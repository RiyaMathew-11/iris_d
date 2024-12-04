defmodule IrisD.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      IrisDWeb.Telemetry,
      IrisD.Repo,
      {DNSCluster, query: Application.get_env(:iris_d, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: IrisD.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: IrisD.Finch},
      # Start a worker by calling: IrisD.Worker.start_link(arg)
      # {IrisD.Worker, arg},
      # Start to serve requests, typically the last entry
      IrisDWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: IrisD.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    IrisDWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
