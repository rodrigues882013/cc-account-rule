defmodule DemoCCAccountRule.Domain.Behaviours.Transaction do
  @callback create(value :: map()) :: :ok | :error | :account_already_initialized
end
