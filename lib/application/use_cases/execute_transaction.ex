defmodule NuAuthorizer.Application.UseCases.ExecuteTransaction do
  @behaviour NuAuthorizer.Application.UseCases.Behaviours.ExecuteTransactionBehaviour

  alias NuAuthorizer.Infrastructure.Repository.TransactionRepository

  @impl NuAuthorizer.Application.UseCases.Behaviours.ExecuteTransactionBehaviour
  def execute({transactions, account}) do

    transactions
    |> valid_transactions(account)
    |> do_transactions(account)

  end

  defp do_transactions(transactions, %{"account" => %{"available-limit" => limit}}) do

    [head | _] = transactions

    transactions
    |> Enum.map_reduce(limit, fn tx, acc -> apply_operation(tx, acc) end)
    |> fn ({txs, _final_balance}) -> txs end.()
    |> Enum.map_reduce(0, fn tx, acc -> apply_time_limit(tx, head, acc) end)
    |> IO.inspect
  end

  defp apply_operation(%{"transaction" => %{"amount" => amount}} = transaction, balance) do

    if balance >= amount do
      {
        transaction
        |> Map.put("after_operation", balance - amount),
        balance - amount
      }
    else
      {
        transaction
        |> Map.put("after_operation", balance)
        |> Map.put("violations", ["insuficient-limit"]),
        balance
      }
    end
  end

  defp apply_time_limit(%{"transaction" => %{"time" => time}} = transaction, %{"transaction" => %{"time" => time_init}}, _acc) do

    IO.inspect(time)
    "teste"
  end

  defp valid_transactions(transactions, account) do
    transactions
  end

  defp valid_transactions(_, account = nil), do: :account_not_initialized
  defp valid_transactions(_, %{"account" => %{"active-card" => false}} = account), do: :card_not_active

  defp is_transaction_frquency_valid(transaction) do

  end

  defp is_double_transaction(transaction) do

  end

  defp process_result(:account_already_initialized = param), do: param
  defp process_result(:error), do: :account_already_initialized
  defp process_result({:ok, _value} = result), do: result

end
