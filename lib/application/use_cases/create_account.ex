defmodule DemoCCAccountRule.Application.UseCases.CreateAccount do
  @behaviour DemoCCAccountRule.Application.UseCases.Behaviours.CreateAccountBehaviour

  alias DemoCCAccountRule.Domain.Account

  @impl DemoCCAccountRule.Application.UseCases.Behaviours.CreateAccountBehaviour
  def execute([%{"account" => _} = account]) do
    account
    |> Account.create
    |> process_result
  end

  @impl DemoCCAccountRule.Application.UseCases.Behaviours.CreateAccountBehaviour
  def execute([]), do: process_result(:account_not_initialized)

  @impl DemoCCAccountRule.Application.UseCases.Behaviours.CreateAccountBehaviour
  def execute(accounts) when length(accounts) > 1 do
    process_result(:account_already_initialized)
  end

  defp process_result(:invalid_parameter), do: :account_creation_error
  defp process_result(:error), do: :account_creation_error
  defp process_result({:ok, value} = _result), do: value
  defp process_result(:account_not_initialized), do: :account_not_initialized
  defp process_result(:account_already_initialized), do: :account_already_initialized

end
