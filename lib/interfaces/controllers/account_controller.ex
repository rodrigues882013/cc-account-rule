defmodule NuAuthorizer.Interface.Controllers.AccountController do
  alias NuAuthorizer.Application.UseCases.CreateAccount

  def create(account_req) do
    account_req
    |> CreateAccount.execute
  end

end
