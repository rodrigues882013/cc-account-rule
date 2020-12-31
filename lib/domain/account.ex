defmodule NuAuthorizer.Domain.Account do
  @behaviour NuAuthorizer.Domain.Behaviours.Account

  defstruct Account: [:active_card, :available_limit]

  @impl NuAuthorizer.Domain.Behaviours.Account
  def create(%{"account" => %{"active-card" =>  _, "available-limit" => _}} = value) do
    {:ok, value}
  end

  @impl NuAuthorizer.Domain.Behaviours.Account
  def create(%{} = _value) do
    :error
  end

  @impl NuAuthorizer.Domain.Behaviours.Account
  def create(_value) do
    :invalid_parameter
  end
end
