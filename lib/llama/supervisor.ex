defmodule Llama.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      {Llama.LogStore, name: Llama.LogStore},
      {Llama.InitStore, name: Llama.InitStore}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end