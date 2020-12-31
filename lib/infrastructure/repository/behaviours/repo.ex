defmodule NuAuthorizer.Infrastructure.Repository.Behaviours.Repo do
  @callback save(term()) :: term() | :error | :invalid_parameters
  @callback find_by_creation_at(term()) :: term() | :error | :invalid_parameters
end
