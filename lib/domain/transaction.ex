defmodule  NuAuthorizer.Application.Domain.Transaction do
  @behaviour NuAuthorizer.Domain.Behaviours.Transaction

  @impl NuAuthorizer.Domain.Behaviours.Transaction
  def create(%{"transaction" => %{"merchant" => _, "amount" => _, "time" => _}} = _value) do
    :ok
  end

  @impl NuAuthorizer.Domain.Behaviours.Transaction
  def create(%{"account" => %{"active-card" =>  _, "available-limit" => _}} = value) do
    :account_already_initialized
  end

  @impl NuAuthorizer.Domain.Behaviours.Transaction
  def create(%{} = _value) do
    :error
  end

end
