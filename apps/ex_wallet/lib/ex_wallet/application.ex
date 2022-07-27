defmodule ExWallet.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      ExWallet.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: ExWallet.PubSub}
      # Start a worker by calling: ExWallet.Worker.start_link(arg)
      # {ExWallet.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: ExWallet.Supervisor)
  end
end
