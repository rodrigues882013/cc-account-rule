defmodule NuAuthorizer.Application.UseCases.ExecuteTransaction do
  @behaviour NuAuthorizer.Application.UseCases.Behaviours.ExecuteTransactionBehaviour

  alias NuAuthorizer.Infrastructure.Repository.TransactionRepository

  @impl NuAuthorizer.Application.UseCases.Behaviours.ExecuteTransactionBehaviour
  def execute({transactions, account}) do
    transactions
    |> do_transactions(account)
  end

  defp do_transactions(transactions, %{"account" => %{"available-limit" => limit}}) do
    [head | tail] = transactions

    tail
    |> Enum.map_reduce({head, 1}, fn tx, acc -> apply_time_limit(tx, acc) end)
    |> get_transformed
    |> Enum.map_reduce(head, fn tx, acc -> apply_time_limit_by_merchant(tx, acc) end)
    |> get_transformed(head, :add_head)
    |> Enum.map_reduce(limit, fn tx, acc -> apply_operation(tx, acc) end)
    |> get_transformed
  end

  defp get_transformed({txs, _final_balance}, head, :add_head), do: [head] ++ txs

  defp get_transformed({txs, _final_balance}), do: txs

  defp apply_operation(%{"transaction" => %{"amount" => amount}} = transaction, balance) do
    violations = Map.get(transaction, "violations", [])

    cond do
      balance < amount ->
        {
          transaction
          |> Map.put("after_operation", balance)
          |> Map.put("violations", violations ++ ["insufficient-limit"]),
          balance
        }
      balance >= amount ->
      if length(violations) == 0 do
        {
          transaction
          |> Map.put("after_operation", balance - amount),
          balance - amount
        }
      else
        { transaction, balance }
      end
    end
  end

  defp apply_time_limit(%{"transaction" => %{"time" => time}} = curr, {%{"transaction" => %{"time" => time_prev}} = prev, allowed_op_counter}) do
    if DateTime.diff(time, time_prev) <= 120 and allowed_op_counter >= 3 do
      violations = Map.get(curr, "violations", [])
      updated = curr |> Map.put("violations", violations ++ ["high-frequency-small-interval"])
      { updated, {updated, 0} }
    else
      { curr, {curr, allowed_op_counter + 1 }}
    end
  end

  defp apply_time_limit_by_merchant(
         %{
           "transaction" => %{
             "time" => curr_time,
             "merchant" => curr_merchant
           }
         } = curr,
         %{
           "transaction" => %{
             "time" => prev_time,
             "merchant" => prev_merchant
           }
         } = prev) do

    if is_doubled_transaction(prev_merchant, curr_merchant, prev_time, curr_time) do
      violations = Map.get(curr, "violations", [])
      updated = curr |> Map.put("violations", violations ++ ["doubled-transaction"])
      { updated, updated }
    else
      { curr, curr }
    end
  end

  defp is_doubled_transaction(merchant_name_prev, merchant_name_curr, transaction_time_prev, transaction_time_curr) do
    if (merchant_name_prev == merchant_name_curr and DateTime.diff(transaction_time_curr, transaction_time_prev) <= 120) do
      true
    else
      false
    end
  end
  defp valid_transactions(_, account = nil), do: :account_not_initialized
  defp valid_transactions(_, %{"account" => %{"active-card" => false}} = account), do: :card_not_active

  defp process_result(:account_already_initialized = param), do: param
  defp process_result(:error), do: :account_already_initialized
  defp process_result({:ok, _value} = result), do: result

end
