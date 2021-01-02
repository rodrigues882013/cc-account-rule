defmodule NuAuthorizer.Interface.Controllers.TransactionController do
  alias NuAuthorizer.Application.UseCases.CreateTransactions
  alias NuAuthorizer.Application.UseCases.ExecuteTransaction


  def create(account, transaction_req) do
    transaction_req
    |> CreateTransactions.execute
    |> ExecuteTransaction.execute(account)
  end

end