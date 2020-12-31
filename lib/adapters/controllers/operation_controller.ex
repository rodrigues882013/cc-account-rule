defmodule NuAuthorizer.Adapters.Controllers.OperationController do
  alias NuAuthorizer.Application.UseCases.CreateAccount
  alias NuAuthorizer.Application.UseCases.CreateTransactions
  alias NuAuthorizer.Application.UseCases.ExecuteTransaction


  def run() do
    IO.stream(:stdio, :line)
    |> split_operations
    |> create_account
    |> create_transactions
    |> dispatch_transaction
    |> process_response

  end

  defp dispatch_transaction(data) do
    data
    |> ExecuteTransaction.execute
  end

  defp split_operations(stream_data) do
    stream_data
    |> Enum.join("")
    |> String.split("\n")
    |> Enum.map(&(Jason.decode!/1))
    |> Enum.split_with(&match?(%{"account" => _}, &1))
  end

  defp create_account({account_req, data}) do
    account_req
    |> CreateAccount.execute
    |> return_tuple(data)
  end

  defp create_transactions({data, transaction_req}) do
    transaction_req
    |> CreateTransactions.execute
    |> return_tuple(data)

  end

  defp return_tuple(first, second), do: {first, second}
  defp process_response(_result), do: "dada"
end
