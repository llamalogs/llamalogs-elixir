defmodule Llama do
  use Application

  @impl true
  def start(_type, _args) do
    # Although we don't use the supervisor name below directly,
    # it can be useful when debugging or introspecting the system.
    Llama.Supervisor.start_link(name: Llama.Supervisor)
  end

  def init(opts \\ %{}) do
    account_key = opts[:account_key] || ""
    graph_name = opts[:graph_name] || ""
    Llama.InitStore.update(%{accountKey: account_key, graphName: graph_name})
  end

  def log(params \\ %{}) do
    Llama.LogStore.log(params)
  end
end
