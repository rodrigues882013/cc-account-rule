defmodule NuAuthorizer.Application.UseCases.CreateAccount do
  @behaviour NuAuthorizer.Application.UseCases.Behaviours.CreateAccountBehaviour

  alias NuAuthorizer.Domain.Account
  alias NuAuthorizer.Infrastructure.Repository.AccountRepository



  @impl NuAuthorizer.Application.UseCases.Behaviours.CreateAccountBehaviour
  def execute([%{"account" => _} = account]) do
    account
    |> Account.create
    |> process_result
  end

  @impl NuAuthorizer.Application.UseCases.Behaviours.CreateAccountBehaviour
  def execute(_), do: process_result()


  defp process_result(:invalid_parameter), do: :account_creation_error
  defp process_result(:error), do: :account_unknown_error
  defp process_result({:ok, value} = _result), do: value
  defp process_result, do: :account_already_initialized
end
