defmodule LlamaLogs.InitStore do
  use Agent

  def start_link(_opts) do
    init_value = %{
        account_key: "",
        graph_name: "",
        disabled: false,
        is_dev_env: false
    }
    Agent.start_link(fn -> init_value end, name: __MODULE__)
  end

  def value do
    Agent.get(__MODULE__, & &1)
  end

  def graph_name do
    value().graph_name
  end

  def account_key do
    value().account_key
  end

  def disabled do 
    value().disabled
  end

  def is_dev_env do
    value().is_dev_env
  end

  def update(new_value) do
    new_account_key = new_value[:account_key] || ""
    new_graph_name = new_value[:graph_name] || ""
    new_is_dev_env = new_value[:is_dev_env] || false
    new_disabled = new_value[:disabled] || false

    Agent.update(__MODULE__, fn _state -> %{
        account_key: new_account_key,
        graph_name: new_graph_name,
        disabled: new_disabled,
        is_dev_env: new_is_dev_env
    } end)
  end
end