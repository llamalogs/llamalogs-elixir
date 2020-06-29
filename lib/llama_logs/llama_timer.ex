defmodule LlamaLogs.Timer do
  def run_time() do
    :timer.sleep(59500)
    LlamaLogs.Proxy.send_messages()
    run_time()
  end

  def start_link() do
    pid = Process.spawn(fn -> run_time() end, [])
    {:ok, pid}
  end
end