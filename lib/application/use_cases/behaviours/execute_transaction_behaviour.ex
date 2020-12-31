defmodule NuAuthorizer.Application.UseCases.Behaviours.ExecuteTransactionBehaviour do
  @callback execute({term(), term()}) :: {:ok, term()} | :error | :invalid_parameter
end
