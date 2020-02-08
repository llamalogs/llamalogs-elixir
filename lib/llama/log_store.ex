defmodule Llama.LogStore do
  use GenServer

  def init(:ok) do
    IO.puts("init log store")
    {:ok, init_state() }
  end

  def init_state() do
    %{ aggregate_logs: %{} }
  end

  def handle_call({:lookup, name}, _from, names) do
    {:reply, Map.fetch(names, name), names}
  end

  def handle_call({:get_logs}, _from, state) do
    %{aggregate_logs: log_groups} = state
    {:reply, log_groups, state}
  end

  def handle_call({:get_and_clear_state}, _from, state) do
    {:reply, state, init_state()}
  end

# Llama.LogStore.add_log(%{sender: "hi", receiver: "bye", log: "this is log"})
  def handle_cast({:add_message, message}, state) do
    Llama.Timer.add_time()

    initObject = fn () -> 
			%{
				sender: message[:sender] || "",
				receiver: message[:receiver] || "",
				account: message[:account] || "",
				total: 0,
				errors: 0,
				elapsed: 0,
				log: "",
				errorLog: "",
				initialMessageCount: 0,
				graph: message[:graph] || ""
			}
		end

    %{aggregate_logs: log_groups} = state
    sender = String.to_atom(message[:sender])
    receiver = String.to_atom(message[:receiver])
    # deconstructing ob
    existing_sender_log_group = Map.get(log_groups, sender, %{})
    new_log = Map.get(existing_sender_log_group, receiver, initObject.())
      |> update_error_count(message[:error])
      |> update_initial_message_count(message[:initial_message])
      |> update_elapsed(message[:elapsed])
      |> update_total_count()
      |> add_logs(message[:error], message[:log])

    # rewrapping ob
    new_sender_log_group = Map.put(existing_sender_log_group, receiver, new_log)
    new_log_groups = Map.put(log_groups, sender, new_sender_log_group)

    new_state = %{aggregate_logs: new_log_groups}
    IO.inspect new_state
    {:noreply, new_state}
  end

  def update_error_count(log, message_error) do
    new_count = case message_error do
      nil -> log.errors
      false -> log.errors
      _ -> log.errors + 1
    end

    %{log | errors: new_count}
  end

  def update_initial_message_count(log, message_initial_message) do 
    new_count = case message_initial_message do
      nil -> log.initialMessageCount
      false -> log.initialMessageCount
      _ -> log.initialMessageCount + 1
    end

    %{log | initialMessageCount: new_count}
  end

  def update_total_count(log) do
    %{log | total: log.total + 1}
  end

  def update_elapsed(log, message_elapsed) do
    elapsed = case message_elapsed do
      nil -> log.elapsed
      false -> log.elapsed
      _ -> prevAmount = log.elapsed * log.total
        (prevAmount + message_elapsed) / (log.total + 1)
    end
    %{log | elapsed: elapsed}
  end

  def add_logs(log, message_error, message_log) do
    new_log = if (log.log == "" && !message_error), do: message_log, else: log.log
    error_log = if (log.errorLog == "" && message_error), do: message_log, else: log.errorLog
    %{log | log: new_log, errorLog: error_log}
  end
  
  # Llama.LogStore.log(%{sender: "blah", receiver: "back", graphName: "graph1", log: "this is a log"})
  def log(params) do
    startTimestamp = :os.system_time(:millisecond)
    defaults = %{sender: "", receiver: "", log: "", graphName: "", accountKey: ""}
    %{
      sender: sender, 
      receiver: receiver, 
      log: log, 
      graphName: graphName, 
      accountKey: accountKey
    } = Map.merge(defaults, params)

    IO.inspect Map.merge(defaults, params)

    if (sender != "" && receiver != "") do
      if (graphName != "" || Llama.InitStore.graphName != "") do

        IO.puts "got ehre"

        message = %{
          sender: sender,
          receiver: receiver,
          timestamp: startTimestamp,
          log: log || "",
          initial_message: true,
          account: accountKey || Llama.InitStore.accountKey || -1,
          graph: graphName || Llama.InitStore.graphName || ""
        }

        add_message(message)

        return_log_data = %{
          sender: receiver,
          receiver: sender,
          startTimestamp: startTimestamp,
          initial_message: false,
          account: accountKey || Llama.InitStore.accountKey || -1,
          graph: graphName || Llama.InitStore.graphName || ""
        }

        return_log_data
      end
    end
  end

  def return_log(data, other_data \\ %{}) do
    defaults = %{error: false, log: ""}
    %{
      error: error, 
      log: log
    } = Map.merge(defaults, other_data)

    endTimestamp = :os.system_time(:millisecond)
    message = Map.merge(data, %{
      startTimestamp: nil,
      timestamp: endTimestamp,
      elapsed: endTimestamp - data.startTimestamp,
      error: error,
      log: log,

    })

    add_message(message)
  end

   @doc """
  Starts the registry.
  """
  def start_link(opts) do
    IO.puts("start link log store")
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Looks up the bucket pid for `name` stored in `server`.

  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  @doc """
  Ensures there is a bucket associated with the given `name` in `server`.
  """
  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end

  def get_logs() do
    GenServer.call(__MODULE__, {:get_logs})
  end

  def get_and_clear_state() do
    GenServer.call(__MODULE__, {:get_and_clear_state})
  end

  def add_message(message) do
    GenServer.cast(__MODULE__, {:add_message, message})
  end
end