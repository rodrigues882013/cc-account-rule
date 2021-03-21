defmodule DemoCCAccountRule.Application.UseCases.Behaviours.CreateTransactionBehaviour do
  @callback execute(term()) :: term() | :error | :invalid_parameter
end
