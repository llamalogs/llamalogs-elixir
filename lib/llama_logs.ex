defmodule LlamaLogs do
  use Application

  @impl true
  def start(_type, _args) do
    # Although we don't use the supervisor name below directly,
    # it can be useful when debugging or introspecting the system.
    LlamaLogs.Supervisor.start_link(name: LlamaLogs.Supervisor)
  end

  def init(opts \\ %{}) do
    account_key = opts[:account_key] || ""
    graph_name = opts[:graph_name] || ""
    LlamaLogs.InitStore.update(%{accountKey: account_key, graphName: graph_name})
  end

  def stop() do
    Supervisor.stop(LlamaLogs.Supervisor)
  end

  def point_stat(params \\ %{}) do
    LlamaLogs.LogAggregator.stat(params, "point")
  end

  def avg_stat(params \\ %{}) do
    LlamaLogs.LogAggregator.stat(params, "average")
  end

  def max_stat(params \\ %{}) do
    LlamaLogs.LogAggregator.stat(params, "max")
  end

  def log(params \\ %{}, return_log \\ %{}) do
    IO.inspect("llama:log")
    LlamaLogs.LogAggregator.log(params, return_log)
  end

  def force_send() do
    LlamaLogs.Proxy.send_messages()
  end
end
