defmodule DemoCCAccountRule.Domain.Account do
  @behaviour DemoCCAccountRule.Domain.Behaviours.Account

  @impl DemoCCAccountRule.Domain.Behaviours.Account
  def create(
        %{
          "account" => %{
            "active-card" => _,
            "available-limit" => _
          }
        } = value
      ) do
    {:ok, value}
  end

  @impl DemoCCAccountRule.Domain.Behaviours.Account
  def create(%{} = _value) do
    :error
  end

  @impl DemoCCAccountRule.Domain.Behaviours.Account
  def create(_value) do
    :invalid_parameter
  end
end
