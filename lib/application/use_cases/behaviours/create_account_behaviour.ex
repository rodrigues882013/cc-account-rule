defmodule NuAuthorizer.Application.UseCases.Behaviours.CreateAccountBehaviour do
  @callback execute(term()) :: {:ok, term()} | :error | :invalid_parameter
end
