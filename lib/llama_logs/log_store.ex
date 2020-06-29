defmodule LlamaLogs.LogStore do
  use GenServer

  def init(:ok) do
    {:ok, init_state() }
  end

  def init_state() do
    %{ 
      aggregate_logs: %{},
      aggregate_stats: %{}
     }
  end

  def get_logs() do
    GenServer.call(__MODULE__, {:get_logs})
  end

  def get_and_clear_logs() do
    GenServer.call(__MODULE__, {:get_and_clear_logs})
  end

  def add_log(message) do
    GenServer.cast(__MODULE__, {:add_log, message})
  end

  def add_point_stat(message) do
    GenServer.cast(__MODULE__, {:add_point_stat, message})
  end

  def add_avg_stat(message) do
    GenServer.cast(__MODULE__, {:add_avg_stat, message})
  end

  def add_max_stat(message) do
    GenServer.cast(__MODULE__, {:add_max_stat, message})
  end

  # def handle_call({:lookup, name}, _from, names) do
  #   {:reply, Map.fetch(names, name), names}
  # end

  def handle_call({:get_logs}, _from, state) do
    %{aggregate_logs: log_groups} = state
    {:reply, log_groups, state}
  end

  def handle_call({:get_and_clear_logs}, _from, state) do
    {:reply, state, init_state()}
  end

  def handle_cast({:add_point_stat, stat}, state) do
    %{aggregate_stats: stat_groups} = state
    component = String.to_atom(stat[:component])
    name = String.to_atom(stat[:name])

    existing_sender_stat_group = Map.get(stat_groups, component, %{})
    # rewrapping ob
    new_component_stat_group = Map.put(existing_sender_stat_group, name, stat)
    new_stat_groups = Map.put(stat_groups, component, new_component_stat_group)

    new_state = %{state | aggregate_stats: new_stat_groups}
    IO.inspect new_state
    {:noreply, new_state}
  end

  def handle_cast({:add_max_stat, stat}, state) do
    %{aggregate_stats: stat_groups} = state
    component = String.to_atom(stat[:component])
    name = String.to_atom(stat[:name])

    existing_sender_stat_group = Map.get(stat_groups, component, %{})
    existing_name_stat = Map.get(stat_groups, name, stat)

    new_max_stat = if (stat.value > existing_name_stat.value), do: stat, else: existing_name_stat

    # rewrapping ob
    new_component_stat_group = Map.put(existing_sender_stat_group, name, new_max_stat)
    new_stat_groups = Map.put(stat_groups, component, new_component_stat_group)

    new_state = %{state | aggregate_stats: new_stat_groups}
    IO.inspect new_state
    {:noreply, new_state}
  end

  def handle_cast({:add_avg_stat, stat}, state) do
    %{aggregate_stats: stat_groups} = state
    component = String.to_atom(stat[:component])
    name = String.to_atom(stat[:name])

    existing_sender_stat_group = Map.get(stat_groups, component, %{})
    existing_name_stat = Map.get(stat_groups, name, stat)

    count = existing_name_stat[:count] || 1
    existing_value = existing_name_stat[:value]
    new_avg_stat = %{existing_name_stat | count: count + 1, value: existing_value + stat[:value]}

    # rewrapping ob
    new_component_stat_group = Map.put(existing_sender_stat_group, name, new_avg_stat)
    new_stat_groups = Map.put(stat_groups, component, new_component_stat_group)

    new_state = %{state | aggregate_stats: new_stat_groups}
    IO.inspect new_state
    {:noreply, new_state}
  end

  def handle_cast({:add_log, message}, state) do
    # LlamaLogs.Timer.add_time()

    %{aggregate_logs: log_groups} = state
    sender = String.to_atom(message[:sender])
    receiver = String.to_atom(message[:receiver])
    # deconstructing ob
    existing_sender_log_group = Map.get(log_groups, sender, %{})
    new_log = Map.get(existing_sender_log_group, receiver, LlamaLogs.LogStore.init_object(message))
      |> update_error_count(message[:is_error])
      |> update_initial_message_count(message[:initial_message])
      |> update_elapsed(message[:elapsed])
      |> update_total_count()
      |> add_logs(message[:is_error], message[:message])

    # rewrapping ob
    new_sender_log_group = Map.put(existing_sender_log_group, receiver, new_log)
    new_log_groups = Map.put(log_groups, sender, new_sender_log_group)

    new_state = %{state | aggregate_logs: new_log_groups}
    IO.inspect new_state
    {:noreply, new_state}
  end

  def init_object(message) do
    %{
        sender: message[:sender] || "",
        receiver: message[:receiver] || "",
        account: message[:account] || "",
        total: 0,
        errors: 0,
        elapsed: 0,
        elapsed_count: 0,
        message: "",
        errorMessage: "",
        initialMessageCount: 0,
        graph: message[:graph] || ""
    }
  end

  def update_error_count(log, message_error) do
    new_count = case message_error do
      true -> log.errors + 1
      _ -> log.errors
    end

    %{log | errors: new_count}
  end

  def update_initial_message_count(log, message_initial_message) do 
    new_count = case message_initial_message do
      true -> log.initialMessageCount + 1
      _ -> log.initialMessageCount
    end

    %{log | initialMessageCount: new_count}
  end

  def update_total_count(log) do
    %{log | total: log.total + 1}
  end

  def update_elapsed(log, message_elapsed) do
    {elapsed, elapsed_count} = case message_elapsed do
      0 -> {log.elapsed, log.elapsed_count}
      nil -> {log.elapsed, log.elapsed_count}
      _ -> prevAmount = log.elapsed * log.elapsed_count
        elapsed = (prevAmount + message_elapsed) / (log.elapsed_count + 1)
        {elapsed, log.elapsed_count + 1}
    end

    %{log | elapsed: elapsed, elapsed_count: elapsed_count}
  end

  def add_logs(log, message_error, message_log) do
    new_log = if (log.log == "" && !message_error), do: message_log, else: log.log
    error_log = if (log.errorLog == "" && message_error), do: message_log, else: log.errorLog
    %{log | log: new_log, errorLog: error_log}
  end

  def start_link(opts) do
    resp = GenServer.start_link(__MODULE__, :ok, opts)
    resp
  end

end