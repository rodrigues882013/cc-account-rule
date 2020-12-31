defmodule  NuAuthorizer.Domain.Transaction do
  @behaviour NuAuthorizer.Domain.Behaviours.Transaction

  @impl NuAuthorizer.Domain.Behaviours.Transaction
  def create(%{"transaction" => %{"amount" => ammount, "merchant" => merchant, "time" => time}}) do
    {
      :ok,
      %{
        "transaction" => %{
          "amount" => ammount,
          "merchant" => merchant,
          "time" => to_datetime(time)
        }
      }
    }
  end

  @impl NuAuthorizer.Domain.Behaviours.Transaction
  def create(%{} = _value) do
    :error
  end

  @impl NuAuthorizer.Domain.Behaviours.Transaction
  def create(_value) do
    :invalid_parameter
  end

  defp to_datetime(value) do
    {:ok, datetime, 0} = DateTime.from_iso8601(value)
    datetime
  end
end
