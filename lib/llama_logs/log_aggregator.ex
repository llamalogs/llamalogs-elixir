defmodule LlamaLogs.LogAggregator do
  def stat(params, type) do 
    defaults = %{
      component: "",
      timestamp: :os.system_time(:millisecond),
      name: "",
      value: 0,
      type: type,
      accountKey: LlamaLogs.InitStore.accountKey || "", 
      graphName: LlamaLogs.InitStore.graphName || "",
    }

    stat = Map.merge(defaults, params)
    api_stat = stat_param_to_api_format(stat)

    case type do
      "point" -> LlamaLogs.LogStore.add_point_stat(api_stat)
      "average" -> LlamaLogs.LogStore.add_avg_stat(api_stat)
      "max" -> LlamaLogs.LogStore.add_max_stat(api_stat)
    end
  end

  def stat_param_to_api_format(stat) do
    %{
        component: stat[:component],
				timestamp: stat[:timestamp],
				name: stat[:name],
				value: stat[:value],
				type: stat[:type],
				account: stat[:accountKey],
				graph: stat[:graphName]
    }
  end

  def log(params, return_log \\ %{}) do
    IO.inspect "log add: log"
    IO.inspect params

    defaults = %{
      sender: "", 
      receiver: "", 
      log: "", 
      error: false, 
      elapsed: 0,
      accountKey: LlamaLogs.InitStore.accountKey, 
      graphName: LlamaLogs.InitStore.graphName,
      initial_message: true
    }

    w_return = Map.merge(defaults, return_log)
    message = Map.merge(w_return, params)

    IO.inspect message

    if (message[:sender] != "" && message[:receiver] != "" && message[:graphName] != "") do
        start_timestamp = :os.system_time(:millisecond)

        api_message = log_param_to_api_format(message, start_timestamp)
        LlamaLogs.LogStore.add_log(api_message)

        return_log_data = create_return_log(message, start_timestamp)
        return_log_data
    end
  end

  def log_param_to_api_format(log, start_timestamp) do
    elapsed = case log[:initial_message] do
      false -> start_timestamp - log[:start_timestamp]
      _ -> 0
    end

    %{
      sender: log[:sender],
      receiver: log[:receiver],
      timestamp: start_timestamp,
      log: Kernel.inspect(log[:log]),
      initial_message: log[:initial_message],
      account: log[:accountKey],
      graph: log[:graphName],
      error: log[:error],
      elapsed: elapsed
    }
  end

  def create_return_log(log, start_timestamp) do
    %{
      sender: log[:receiver],
      receiver: log[:sender],
      start_timestamp: start_timestamp,
      initial_message: false,
      accountKey: log[:accountKey],
      graphName: log[:graphName]
    }
  end

end