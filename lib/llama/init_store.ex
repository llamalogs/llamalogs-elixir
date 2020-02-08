defmodule Llama.InitStore do
  use Agent

  def start_link(_opts) do
    IO.puts("start link init store")
    init_value = %{
        accountKey: "",
        graphName: ""
    }
    Agent.start_link(fn -> init_value end, name: __MODULE__)
  end

  def value do
    Agent.get(__MODULE__, & &1)
  end

  def graphName do
    value().graphName
  end

  def accountKey do
    value().accountKey
  end

  def update(new_value) do
    new_account_key = new_value[:accountKey] || ""
    new_graph_name = new_value[:graphName] || ""
    Agent.update(__MODULE__, fn _state -> %{
        accountKey: new_account_key,
        graphName: new_graph_name
    } end)
  end
end