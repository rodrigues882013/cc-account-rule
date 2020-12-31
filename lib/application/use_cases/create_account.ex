defmodule NuAuthorizer.Application.UseCases.CreateAccount do
  @behaviour NuAuthorizer.Application.UseCases.Behaviours.CreateAccountBehaviour

  alias NuAuthorizer.Domain.Account

  @impl NuAuthorizer.Application.UseCases.Behaviours.CreateAccountBehaviour
  def execute(value) do
    value
    |> Account.create
    |> process_result
  end

  defp process_result(:account_already_initialized = value), do: value
  defp process_result(:error), do: :account_already_initialized
  defp process_result({:ok, _value} = result), do: result
end
