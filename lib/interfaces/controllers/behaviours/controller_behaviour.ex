defmodule NuAuthorizer.Interfaces.Controllers.Behaviours.ControllerBehaviour do
  @callback create(term(), term()) :: term()
end
