defmodule NuAuthorizer.Application.UseCases.CreateTransactions do
  @behaviour NuAuthorizer.Application.UseCases.Behaviours.CreateTransactionBehaviour

  alias NuAuthorizer.Domain.Transaction

  @impl NuAuthorizer.Application.UseCases.Behaviours.CreateTransactionBehaviour
  def execute(transactions) when is_list(transactions) do
    transactions
    |> Enum.map(&(create_one/1))
  end

  @impl NuAuthorizer.Application.UseCases.Behaviours.CreateTransactionBehaviour
  def execute(transactions) do
    transactions
    |> process_result
  end

  defp create_one(transaction) do
    transaction
    |> Transaction.create
    |> process_result
  end

  defp process_result({:transaction_invalid_parameter, transaction_with_errors}), do: transaction_with_errors
  defp process_result(:invalid_parameter), do: :transaction_creation_error
  defp process_result(:error), do: :transaction_unknown_error
  defp process_result({:ok, value} = _result), do: value

end
