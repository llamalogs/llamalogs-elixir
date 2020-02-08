defmodule Llama.Timer do
  use GenServer

  def init(:ok) do
    IO.puts("init timer store")
    {:ok, init_state() }
  end

  def init_state() do
    %{ last_time_sent: :os.system_time(:millisecond), timeout_pid: nil }
  end

  def handle_call({:lookup, name}, _from, names) do
    {:reply, Map.fetch(names, name), names}
  end

  def handle_cast({:clear_pid}, _state) do
    {:noreply, init_state()}
  end

  def handle_cast({:add_time}, state) do
      cond do
        !state.timeout_pid || !Process.alive?(state.timeout_pid) ->
          pid = create_new_timer_process()
          new_state = Map.put(state, :timeout_pid, pid)
          {:noreply, new_state}

        :os.system_time(:millisecond) - state.last_time_sent > 24500 ->
          IO.inspect :os.system_time(:millisecond) - state.last_time_sent
          {:noreply, state}

        true -> 
          Process.exit(state.timeout_pid, :kill)
          pid = create_new_timer_process()
          new_state = Map.put(state, :timeout_pid, pid)
          {:noreply, new_state}
        end
  end

  def create_new_timer_process() do
    Process.spawn(fn -> 
        :timer.sleep(5000)
        IO.inspect "timer off"
        Llama.Timer.clear_pid()
        %{aggregate_logs: aggregate_logs} = Llama.LogStore.get_and_clear_state()
        Llama.Proxy.send_messages(aggregate_logs, %{})
        
    end, [])
  end


   @doc """
  Starts the registry.
  """
  def start_link(opts) do
    IO.puts("start link timer store")
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def add_time() do  
    GenServer.cast(__MODULE__, {:add_time})
  end

  def clear_pid() do
    GenServer.cast(__MODULE__, {:clear_pid})
  end

  def get_logs() do
    GenServer.call(__MODULE__, {:get_logs})
  end

  def add_message(message) do
    GenServer.cast(__MODULE__, {:add_message, message})
  end
end