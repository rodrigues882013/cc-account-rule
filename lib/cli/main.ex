defmodule DemoCCAccountRule.CLI do
  require Logger

  alias DemoCCAccountRule.Interface.Orchestrator

  def main(_args \\ []), do: init()

  defp init() do
    Logger.info("Starting up application.....")
    start_application()
    Logger.info("Ending up application.....")

  end

  defp start_application(), do: Orchestrator.run()

end
