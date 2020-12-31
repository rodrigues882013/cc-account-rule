defmodule NuAuthorizer.Application.UseCases.Behaviours.CreateAccountBehaviour do
  @callback execute(term()) :: term() | :error | :invalid_parameter
end
