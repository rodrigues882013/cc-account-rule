defmodule NuAuthorizer.Application.UseCases.ExecuteTransaction do
  @behaviour NuAuthorizer.Application.UseCases.Behaviours.ExecuteTransactionBehaviour

  @impl NuAuthorizer.Application.UseCases.Behaviours.ExecuteTransactionBehaviour
  def execute(
          transactions,
          %{
            "account" => %{
              "active-card" => true
            }
          } = account

      ) do

    {safe_transactions, transactions_with_previous_errors} =
      transactions |> Enum.split_with( fn tx -> has_no_previous_transaction_errors(tx) end)

    safe_transactions
    |> Enum.filter( fn tx -> has_no_previous_transaction_errors(tx) end)
    |> do_transactions(account)
    |> merge(transactions_with_previous_errors)
  end

  @impl NuAuthorizer.Application.UseCases.Behaviours.ExecuteTransactionBehaviour
  def execute(
          transactions,
          %{
            "account" => %{
              "active-card" => false
            }
          } = _account

      ) do
    transactions
    |> Enum.map(fn tx -> apply_credit_card_rule(tx) end)
  end

  @impl NuAuthorizer.Application.UseCases.Behaviours.ExecuteTransactionBehaviour
  def execute(transactions, :account_not_initialized) do
    transactions
    |> Enum.map(fn tx -> apply_account_not_initialized_rule(tx) end)
  end

  @impl NuAuthorizer.Application.UseCases.Behaviours.ExecuteTransactionBehaviour
  def execute(transactions, :account_already_initialized) do
    transactions
    |> Enum.map(fn tx -> apply_account_already_initialized_rule(tx) end)
  end

  @impl NuAuthorizer.Application.UseCases.Behaviours.ExecuteTransactionBehaviour
  def execute(transactions, :account_creation_error) do
    transactions
    |> Enum.map(fn tx -> apply_account_creation_error_rule(tx) end)
  end

  defp do_transactions(
         transactions,
         %{
           "account" => %{
             "available-limit" => limit,
             "active-card" => _is_active
           }
         }
       ) do
    [head | tail] = transactions

    tail
    |> Enum.map_reduce({head, 1}, fn tx, acc -> apply_time_limit_rule(tx, acc) end)
    |> get_transformed
    |> Enum.map_reduce(head, fn tx, acc -> apply_time_limit_by_merchant_rule(tx, acc) end)
    |> get_transformed(head, :add_head)
    |> Enum.map_reduce(limit, fn tx, acc -> apply_balance_rule(tx, acc) end)
    |> get_transformed
  end

  defp get_transformed({txs, _final_balance}, head, :add_head), do: [head] ++ txs
  defp get_transformed({txs, _final_balance}), do: txs

  defp apply_credit_card_rule(
         %{
           "transaction" => %{
             "amount" => _amount
           }
         } = transaction
       ) do
    transaction
    |> Map.put("violations", ["card-not-active"])
  end

  defp apply_account_not_initialized_rule(%{"transaction" => _ } = transaction) do
    transaction
    |> Map.put("violations", ["account-not-initialized"])
  end

  defp apply_account_already_initialized_rule(%{"transaction" => _} = transaction) do
    transaction
    |> Map.put("violations", ["account-already-initialized"])
  end

  defp apply_account_creation_error_rule(%{"transaction" => _} = transaction) do
    transaction
    |> Map.put("violations", ["account-creation-error"])
  end

  defp apply_balance_rule(
         %{
           "transaction" => %{
             "amount" => amount
           }
         } = transaction,
         balance
       ) do
    violations = Map.get(transaction, "violations", [])

    cond do
      balance < amount ->
        {
          transaction
          |> Map.put("before-operation", balance)
          |> Map.put("after-operation", balance)
          |> Map.put("violations", violations ++ ["insufficient-limit"]),
          balance
        }
      balance >= amount ->
        if length(violations) == 0 do
          {
            transaction
            |> Map.put("before-operation", balance)
            |> Map.put("after-operation", balance - amount),
            balance - amount
          }
        else
          {
            transaction
            |> Map.put("before-operation", balance)
            |> Map.put("after-operation", balance),
            balance
          }
        end
    end
  end

  defp apply_time_limit_rule(
         %{
           "transaction" => %{
             "time" => time
           }
         } = curr,
         {
           %{
             "transaction" => %{
               "time" => time_prev
             }
           } = _prev,
           allowed_op_counter
         }
       ) do
    if DateTime.diff(time, time_prev) <= 120 and allowed_op_counter >= 3 do
      violations = Map.get(curr, "violations", [])
      updated = curr
                |> Map.put("violations", violations ++ ["high-frequency-small-interval"])
      {updated, {updated, 0}}
    else
      {curr, {curr, allowed_op_counter + 1}}
    end
  end

  defp apply_time_limit_by_merchant_rule(
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
         } = _prev
       ) do

    if is_doubled_transaction(prev_merchant, curr_merchant, prev_time, curr_time) do
      violations = Map.get(curr, "violations", [])
      updated = curr
                |> Map.put("violations", violations ++ ["doubled-transaction"])
      {updated, updated}
    else
      {curr, curr}
    end
  end

  defp is_doubled_transaction(merchant_name_prev, merchant_name_curr, transaction_time_prev, transaction_time_curr) do
    if (
         merchant_name_prev == merchant_name_curr and DateTime.diff(
           transaction_time_curr,
           transaction_time_prev
         ) <= 120) do
      true
    else
      false
    end
  end

  defp has_no_previous_transaction_errors(transaction) do
    previous_violations = transaction |> Map.get("violations")
    previous_violations == nil
  end

  defp merge(executed_transactions, transaction_with_previous_errors) do
    executed_transactions ++ transaction_with_previous_errors
    |> Enum.sort(fn first, second -> comparable(first, second) end)
  end

  def comparable(_transaction, %{"transaction" => %{"merchant" => _, "amount" => _}, "violations" => _}), do: true
  def comparable(_transaction, %{"transaction" => %{"amount" => _}, "violations" => _}), do: true
  def comparable(%{"transaction" => %{"time" => t1}}, %{"transaction" => %{"time" => t2}}) do
    result = DateTime.compare(t1, t2)
    cond do
      result == :lt -> true
      result == :eq -> true
      result == :gt -> false
    end
  end
end
