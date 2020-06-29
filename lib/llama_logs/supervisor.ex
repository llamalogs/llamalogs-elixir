defmodule LlamaLogs.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
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