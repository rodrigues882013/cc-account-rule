defmodule NuAuthorizer.Interface.Orchestrator do
  alias NuAuthorizer.Interface.Controllers.AccountController
  alias NuAuthorizer.Interface.Controllers.TransactionController
  alias NuAuthorizer.Interface.Serializers.ResultSerializer

  def run() do
    {account_payload, transactions_payload} = IO.read(:stdio, :all)
                                              |> split_operations

    account = dispatch(account_payload)
    transaction = dispatch(account, transactions_payload)

    {account, transaction}
    |> ResultSerializer.serialize
    |> IO.inspect
  end

  defp split_operations(stream_data) do
    stream_data
    |> String.split("\n")
    |> Enum.map(&(Jason.decode! / 1))
    |> Enum.split_with(&match?(%{"account" => _}, &1))
  end

  defp dispatch(account_req), do: AccountController.create(account_req)
  defp dispatch(%{"account" => _} = account, transactions_req),
       do: TransactionController.create(account, transactions_req)
  defp dispatch(error_param, transactions_req),
       do: TransactionController.create(error_param, transactions_req)

end