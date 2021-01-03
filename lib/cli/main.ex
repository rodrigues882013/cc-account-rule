defmodule NuAuthorizer.CLI do
  alias NuAuthorizer.Interface.Orchestrator

  def main(_args \\ []), do: init()

  defp init() do
    start_application()
  end

  defp start_application(), do: Orchestrator.run()

end
