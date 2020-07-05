LlamaLogs.Supervisor.start_link(["link_acc", "link_graph"])
# running tests in order for init
ExUnit.configure seed: 0
ExUnit.start()