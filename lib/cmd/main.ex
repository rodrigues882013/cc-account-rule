defmodule NuAuthorizer.CMD do
  alias NuAuthorizer.Application.UseCases.CreateAccount

  def main(_args \\ []) do
    [head | _tail] = IO.stream(:stdio, :line) |> Enum.join("") |> String.split("\n")

    head
    |> Jason.decode!
    |> CreateAccount.execute
    |> IO.inspect
  end

end
