defmodule DemoCCAccountRule.Interface.Controllers.AccountController do
  @behaviour DemoCCAccountRule.Interfaces.Controllers.Behaviours.ControllerBehaviour

  alias DemoCCAccountRule.Application.UseCases.CreateAccount

  @impl DemoCCAccountRule.Interfaces.Controllers.Behaviours.ControllerBehaviour
  def create(account_req) do
    account_req
    |> CreateAccount.execute
  end

end
