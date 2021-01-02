defmodule NuAuthorizer.Infrastructure.Database do
  use Agent

  def start_link(initial_value) do
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
  end

  def execute_statement(:save, key, value), do: :ok

  def execute_statement(:get, key), do: :ok

  defp get() do
    Agent.get(__MODULE__, & &1)
  end

  defp put() do
    Agent.update(__MODULE__, &(&1 + 1))
  end
end
