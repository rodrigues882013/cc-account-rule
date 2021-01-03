defmodule NuAuthorizer.Interface.Controllers.AccountController do
  @behaviour NuAuthorizer.Interfaces.Controllers.Behaviours.ControllerBehaviour

  alias NuAuthorizer.Application.UseCases.CreateAccount

  @impl NuAuthorizer.Interfaces.Controllers.Behaviours.ControllerBehaviour
  def create(account_req) do
    account_req
    |> CreateAccount.execute
  end

end
