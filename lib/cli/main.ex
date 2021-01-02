defmodule NuAuthorizer.CLI do
  alias NuAuthorizer.Interface.Orchestrator
  alias NuAuthorizer.Infrastructure.Database

  def main(_args \\ []), do: init()

  defp init() do
    set_up_database()
    start_application()
  end

  defp start_application(), do: Orchestrator.run()
  defp set_up_database(), do: Database.start_link(0)

end
