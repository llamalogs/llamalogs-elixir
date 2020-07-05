defmodule LlamaLogs.LogAggregator do
  def stat(params, type) do 
    defaults = %{
      component: "",
      timestamp: :os.system_time(:millisecond),
      name: "",
      value: 0,
      type: type,
      account_key: LlamaLogs.InitStore.account_key || "", 
      graph_name: LlamaLogs.InitStore.graph_name || "",
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
    defaults = %{
      sender: "", 
      receiver: "", 
      message: "", 
      is_error: false, 
      elapsed: 0,
      account_key: LlamaLogs.InitStore.account_key, 
      graph_name: LlamaLogs.InitStore.graph_name,
      initial_message: true
    }

    w_return = Map.merge(defaults, return_log)
    message = Map.merge(w_return, params)

    has_req_fields = message[:sender] != "" && message[:receiver] != "" && message[:graph_name] != "" && message[:account_key] != ""

    cond do
      has_req_fields -> 
        start_timestamp = :os.system_time(:millisecond)

        api_message = log_param_to_api_format(message, start_timestamp)
        LlamaLogs.LogStore.add_log(api_message)

        return_log_data = create_return_log(message, start_timestamp)
        return_log_data
      true -> nil
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
      message: log[:message],
      initial_message: log[:initial_message],
      account: log[:account_key],
      graph: log[:graph_name],
      is_error: log[:is_error],
      elapsed: elapsed
    }
  end

  def create_return_log(log, start_timestamp) do
    %{
      sender: log[:receiver],
      receiver: log[:sender],
      start_timestamp: start_timestamp,
      initial_message: false,
      account_key: log[:accountKey],
      graph_name: log[:graphName]
    }
  end

end