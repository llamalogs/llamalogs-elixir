defmodule LlamaLogs.Supervisor do
  use Supervisor

  def start_link(args) do
    opts = [name: LlamaLogs.Supervisor]
    link = Supervisor.start_link(__MODULE__, :ok, opts)

    account_key = Enum.at(args, 0)
    graph_name = Enum.at(args, 1)
    disabled = Enum.at(args, 2)
    is_dev_env = Enum.at(args, 3)

    LlamaLogs.InitStore.update(%{
      account_key: account_key,
      graph_name: graph_name,
      disabled: disabled,
      is_dev_env: is_dev_env
    })

    link
  end

  @impl true
  def init(:ok) do
    children = [
      {LlamaLogs.LogStore, name: LlamaLogs.LogStore},
      {LlamaLogs.InitStore, name: LlamaLogs.InitStore},
      %{
        id: LlamaLogs.Timer,
        start: {LlamaLogs.Timer, :start_link, []}
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end