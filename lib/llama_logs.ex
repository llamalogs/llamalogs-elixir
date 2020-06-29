defmodule LlamaLogs do

  def start_link(args) do
    {:ok, pid} = LlamaLogs.Supervisor.start_link(name: LlamaLogs.Supervisor)
    [account_key, graph_name] = args
    LlamaLogs.init(%{account_key: account_key, graph_name: graph_name})
    {:ok, pid}
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker
    }
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
    LlamaLogs.LogAggregator.log(params, return_log)
  end

  def force_send() do
    LlamaLogs.Proxy.send_messages()
  end
end
