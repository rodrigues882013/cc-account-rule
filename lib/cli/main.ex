defmodule NuAuthorizer.CLI do
  alias NuAuthorizer.Adapters.Controllers.OperationController
  alias NuAuthorizer.Infrastructure.Database

  def main(_args \\ []), do: init()

  defp init() do
    set_up_database()
    start_application()
  end

  defp start_application() do
    OperationController.run()
    |> IO.inspect
  end
   defp set_up_database(), do: Database.start_link(0)

end
