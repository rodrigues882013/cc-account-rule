defmodule DemoCCAccountRule.Interface.Serializers.ResultSerializer do

  def serialize({account, result}) when is_list(result) do
    account
    |> process_result(result)
  end

  defp process_result(:account_not_initialized = error_param, result) do
    result
    |> Enum.map(fn log -> transform(log, {:error, error_param}) end)
    |> Enum.join("\n")
  end

  defp process_result(:account_already_initialized = error_param, result) do
    result
    |> Enum.map(fn log -> transform(log, {:error, error_param}) end)
    |> Enum.join("\n")
  end

  defp process_result(
         %{
           "account" => %{
             "active-card" => active_card,
             "available-limit" => available_limit
           }
         },
         result
       ) do
    result
    |> Enum.map(fn log -> transform(log, active_card) end)
    |> transform(active_card, available_limit)
    |> Enum.join("\n")

  end

  defp transform(log, {_, _} = _error) do
    %{
      "account" => %{
        "active-card" => false,
        "available-limit" => "not-applicable"
      },
      "violations" => Map.get(log, "violations", [])
    }
    |> Jason.encode!
  end

  defp transform(log, active_card) do
    %{
      "account" => %{
        "active-card" => active_card,
        "available-limit" => log["after-operation"]
      },
      "violations" => Map.get(log, "violations", [])
    }
    |> Jason.encode!
  end

  defp transform(tail, active_card, available_limit) do
    head = %{
             "account" => %{
               "active-card" => active_card,
               "available-limit" => available_limit
             },
             "violations" => []
           }
           |> Jason.encode!

    [head] ++ tail
  end
end
