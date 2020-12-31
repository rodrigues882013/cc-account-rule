defmodule  NuAuthorizer.Application.Service.TransactionService do
  @behaviour NuAuthorizer.Application.Service.Behaviours.Transaction

  @impl NuAuthorizer.Application.Service.Behaviours.Transaction
  def execute(%{"transaction" => %{"merchant" => _, "amount" => _, "time" => _}} = _value) do
    :ok
  end

  @impl NuAuthorizer.Application.Service.Behaviours.Transaction
  def execute(%{} = _value) do
    :error
  end

end
