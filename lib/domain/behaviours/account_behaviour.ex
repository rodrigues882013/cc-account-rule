defmodule NuAuthorizer.Domain.Behaviours.Account do
  @callback create(term()) :: {:ok, term()} | :error | :invalid_parameter
end
