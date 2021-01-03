defmodule NuAuthorizer.Interface.Controllers.TransactionController do
  @behaviour NuAuthorizer.Interfaces.Controllers.Behaviours.ControllerBehaviour

  alias NuAuthorizer.Application.UseCases.CreateTransactions
  alias NuAuthorizer.Application.UseCases.ExecuteTransaction

  @impl NuAuthorizer.Interfaces.Controllers.Behaviours.ControllerBehaviour
  def create(%{"account" => _} = account, transaction_req) do
    transaction_req
    |> CreateTransactions.execute
    |> ExecuteTransaction.execute(account)
  end

  @impl NuAuthorizer.Interfaces.Controllers.Behaviours.ControllerBehaviour
  def create(error_param, transaction_req) do
    transaction_req
    |> CreateTransactions.execute
    |> ExecuteTransaction.execute(error_param)
  end

end