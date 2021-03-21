defmodule DemoCCAccountRule.Interface.Controllers.TransactionController do
  @behaviour DemoCCAccountRule.Interfaces.Controllers.Behaviours.ControllerBehaviour

  alias DemoCCAccountRule.Application.UseCases.CreateTransactions
  alias DemoCCAccountRule.Application.UseCases.ExecuteTransaction

  @impl DemoCCAccountRule.Interfaces.Controllers.Behaviours.ControllerBehaviour
  def create(%{"account" => _} = account, transaction_req) do
    transaction_req
    |> CreateTransactions.execute
    |> ExecuteTransaction.execute(account)
  end

  @impl DemoCCAccountRule.Interfaces.Controllers.Behaviours.ControllerBehaviour
  def create(error_param, transaction_req) do
    transaction_req
    |> CreateTransactions.execute
    |> ExecuteTransaction.execute(error_param)
  end

end
