defmodule NuAuthorizer.Application.UseCases.ExecuteTransaction do
  @behaviour NuAuthorizer.Application.UseCases.Behaviours.ExecuteTransactionBehaviour

  alias NuAuthorizer.Domain.Transaction

  @impl NuAuthorizer.Application.UseCases.Behaviours.ExecuteTransactionBehaviour
  def execute(account, value) do
    value
    |> Transaction.create
    |> process_result
  end

  defp process_result(:account_already_initialized = param), do: param
  defp process_result(:error), do: :account_already_initialized
  defp process_result({:ok, _value} = result), do: result

end
