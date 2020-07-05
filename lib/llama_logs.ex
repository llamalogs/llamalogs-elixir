defmodule LlamaLogs do

  def start_link(args) do
    {:ok, pid} = LlamaLogs.Supervisor.start_link(name: LlamaLogs.Supervisor)
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
    disabled = opts[:disabled] || false
    is_dev_env = opts[:is_dev_env] || false

    LlamaLogs.InitStore.update(%{account_key: account_key, graph_name: graph_name, disabled: disabled, is_dev_env: is_dev_env})
  end

  def stop() do
    Supervisor.stop(LlamaLogs.Supervisor)
  end

  def point_stat(params \\ %{}) do
    cond do
      LlamaLogs.InitStore.disabled -> nil
      true -> 
        LlamaLogs.LogAggregator.stat(params, "point")
    end
  end

  def avg_stat(params \\ %{}) do
    cond do
      LlamaLogs.InitStore.disabled -> nil
      true -> 
        LlamaLogs.LogAggregator.stat(params, "average")
    end
  end

  def max_stat(params \\ %{}) do
    cond do
      LlamaLogs.InitStore.disabled -> nil
      true -> 
        LlamaLogs.LogAggregator.stat(params, "max")
    end
  end

  def log(params \\ %{}, return_log \\ %{}) do
    cond do
      LlamaLogs.InitStore.disabled -> nil
      true -> 
        LlamaLogs.LogAggregator.log(params, return_log)
    end
  end

  def force_send() do
    cond do
      LlamaLogs.InitStore.disabled -> nil
      true -> 
        LlamaLogs.Proxy.send_messages()
    end
  end
end
