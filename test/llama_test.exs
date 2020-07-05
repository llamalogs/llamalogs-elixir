defmodule LlamaTest do
  use ExUnit.Case
  doctest LlamaLogs

  test "supervisor init sets account key and graph name" do
    LlamaLogs.log(%{sender: "send1", receiver: "rec1", message: "hi"})
    {formatted_logs, _formatted_stats} = LlamaLogs.Proxy.collect_messages()
    string_logs = Poison.encode!(formatted_logs)

    expected_logs = "[{\"sender\":\"send1\",\"receiver\":\"rec1\",\"message\":\"hi\",\"initialMessageCount\":1,\"graph\":\"link_graph\",\"errorMessage\":\"\",\"errorCount\":0,\"count\":1,\"account\":\"link_acc\"}]"

    assert string_logs == expected_logs

    LlamaLogs.InitStore.update(%{})
  end

  test "multiple logs" do
    LlamaLogs.log(%{sender: "send1", receiver: "rec1", message: "hi", account_key: "acc2", graph_name: "graph_2"})
    LlamaLogs.log(%{sender: "send1", receiver: "rec1", message: "other", account_key: "acc2", graph_name: "graph_2"})
    LlamaLogs.log(%{sender: "send2", is_error: true, receiver: "rec1", message: "error message", account_key: "acc2", graph_name: "graph_2"})
    LlamaLogs.log(%{sender: "send2", receiver: "rec1", message: "second message", account_key: "acc2", graph_name: "graph_2"})
    {formatted_logs, _formatted_stats} = LlamaLogs.Proxy.collect_messages()
    string_logs = Poison.encode!(formatted_logs)

    expected_logs = "[{\"sender\":\"send1\",\"receiver\":\"rec1\",\"message\":\"hi\",\"initialMessageCount\":2,\"graph\":\"graph_2\",\"errorMessage\":\"\",\"errorCount\":0,\"count\":2,\"account\":\"acc2\"},{\"sender\":\"send2\",\"receiver\":\"rec1\",\"message\":\"second message\",\"initialMessageCount\":2,\"graph\":\"graph_2\",\"errorMessage\":\"error message\",\"errorCount\":1,\"count\":2,\"account\":\"acc2\"}]"

    assert string_logs == expected_logs
  end

  test "disabling client" do
    LlamaLogs.InitStore.update(%{disabled: true})
    LlamaLogs.log(%{sender: "send1", receiver: "rec1", message: "hi", account_key: "acc2", graph_name: "graph_2"})
    LlamaLogs.log(%{sender: "send1", receiver: "rec1", message: "other", account_key: "acc2", graph_name: "graph_2"})
    LlamaLogs.log(%{sender: "send2", is_error: true, receiver: "rec1", message: "error message", account_key: "acc2", graph_name: "graph_2"})
    LlamaLogs.log(%{sender: "send2", receiver: "rec1", message: "second message", account_key: "acc2", graph_name: "graph_2"})
    {formatted_logs, _formatted_stats} = LlamaLogs.Proxy.collect_messages()
    string_logs = Poison.encode!(formatted_logs)

    expected_logs = "[]"

    assert string_logs == expected_logs
  end
end
