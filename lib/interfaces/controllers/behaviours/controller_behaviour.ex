defmodule NuAuthorizer.Interfaces.Controllers.Behaviours.ControllerBehaviour do
  @callback create(term(), term()) :: term()
  @callback create(term()) :: term()
  @optional_callbacks create: 1, create: 2
end
