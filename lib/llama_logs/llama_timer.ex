defmodule LlamaLogs.Timer do
  def run_time() do
    :timer.sleep(5000)
    LlamaLogs.Proxy.send_messages()
    run_time()
  end

  def start_link() do
    IO.puts("start link timer store")
    IO.inspect self()
    pid = Process.spawn(fn -> run_time() end, [])
    {:ok, pid}
  end
end