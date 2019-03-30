defmodule Chatblog.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    curators =
      curator_specs([
        "indieweb",
        "indieweb-dev",
        "indieweb-meta",
        "indieweb-wordpress"
      ])

    # List all child processes to be supervised
    children = [
      Chatblog.Repo,
      ChatblogWeb.Endpoint,
      Chatblog.Lurker,
      {Registry, [keys: :unique, name: Chatblog.Curators]},
      %{
        id: Chatblog.Curators.Supervisor,
        start: {Supervisor, :start_link, [curators, [strategy: :one_for_one]]}
      }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Chatblog.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp curator_specs(channels) do
    Enum.map(channels, fn channel ->
      Supervisor.child_spec(
        {Chatblog.Curator, [channel: channel]},
        id: {Chatblog.Curator, channel}
      )
    end)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ChatblogWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
