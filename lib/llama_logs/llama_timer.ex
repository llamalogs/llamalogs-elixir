defmodule LlamaLogs.Timer do
  def run_time(is_first_send) do
    # sending in after 5 seconds in first run only to quickly show results for consumers
    sleep_time = if is_first_send do 
      5000
    else 
      59500 
    end

    :timer.sleep(sleep_time)
    IO.inspect "sending messages"
    LlamaLogs.Proxy.send_messages()
    run_time(false)
  end

  def start_link() do
    pid = Process.spawn(fn -> run_time(true) end, [])
    {:ok, pid}
  end
end