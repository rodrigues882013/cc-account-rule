defmodule NuAuthorizer do

  def main(_args \\ []) do
    IO.stream(:stdio, :line)
    |> Enum.join("")
    |> String.split("\n")
    |> IO.inspect
  end

end
