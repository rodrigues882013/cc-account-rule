defmodule NuAuthorizer.Interface.Orchestrator do
  alias NuAuthorizer.Interface.Controllers.AccountController
  alias NuAuthorizer.Interface.Controllers.TransactionController
  alias NuAuthorizer.Interface.Serializers.ResultSerializer

#  def run() do
#    {account_payload, transactions_payload} = IO.stream(:stdio, :line)
#                                              |> split_operations
#
#    dispatch(account_payload)
#    |> dispatch(transactions_payload)
#    |> ResultSerializer.serialize
#
#  end

  def run() do

  { account_payload, transactions_payload } =
      {
        [
          %{
            "account" => %{
              "active-card" => true,
              "available-limit" => 100
            }
          }
        ],
        [
          %{
            "transaction" => %{
              "merchant" => "Burger King",
              "amount" => 20,
              "time" => "2019-02-13T11:00:00.000Z"
            }
          },
          %{
            "transaction" => %{
              "merchant" => "Habbib's",
              "amount" => 90,
              "time" => "2019-02-13T11:03:00.000Z"
            }
          },
          %{
            "transaction" => %{
              "merchant" => "Habbib's",
              "amount" => 90,
              "time" => "2019-02-13T11:02:00.000Z"
            }
          },
          %{
            "transaction" => %{
              "merchant" => "Shell",
              "amount" => 90,
              "time" => "2019-02-13T11:01:00.000Z"
            }
          },
          %{
            "transaction" => %{
              "merchant" => "Ipiranga",
              "amount" => 90,
              "time" => "2019-02-13T11:01:01.000Z"
            }
          },
          %{
            "transaction" => %{
              "merchant" => "Ipiranga",
              "amount" => 90,
              "time" => "2019-02-13T11:01:01.002Z"
            }
          },
          %{
            "transaction" => %{
              "merchant" => "Ipiranga",
              "amount" => 5,
              "time" => "2020-02-13T11:01:01.002Z"
            }
          },
          %{
            "transaction" => %{
              "merchant" => "Xevron",
              "amount" => 200,
              "time" => "2020-02-13T20:01:01.002Z"
            }
          }
        ]
      }

    dispatch(account_payload)
    |> dispatch(transactions_payload)
    |> ResultSerializer.serialize

  end

  defp split_operations(stream_data) do
    stream_data
    |> Enum.join("")
    |> String.split("\n")
    |> Enum.map(&(Jason.decode! / 1))
    |> Enum.split_with(&match?(%{"account" => _}, &1))
  end

  defp dispatch([%{"account" => _}] = account), do: AccountController.create(account)
  defp dispatch(%{"account" => _} = account, transactions), do: TransactionController.create(account, transactions)

end