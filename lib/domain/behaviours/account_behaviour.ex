defmodule NuAuthorizer.Domain.Behaviours.Account do

  defstruct Account: [:active_card, :available_limit]

  @callback create(term()) :: {:ok, term()} | :error | :invalid_parameter
end
