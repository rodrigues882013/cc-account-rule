defmodule NuAuthorizer.Adapters.Controllers.OperationController do
  alias NuAuthorizer.Application.UseCases.CreateAccount
  alias NuAuthorizer.Application.UseCases.CreateTransactions
  alias NuAuthorizer.Application.UseCases.ExecuteTransaction

#  def run() do
#    IO.stream(:stdio, :line)
#    |> split_operations
#    |> create_account
#    |> create_transactions
#    |> dispatch_transaction
#    |> process_response
#
#  end

  def run() do

    mock_operation =
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
    |> create_account
    |> create_transactions
    |> dispatch_transaction
    |> process_response

  end

  defp dispatch_transaction(data) do
    data
    |> ExecuteTransaction.execute
  end

  defp split_operations(stream_data) do
    stream_data
    |> Enum.join("")
    |> String.split("\n")
    |> Enum.map(&(Jason.decode!/1))
    |> Enum.split_with(&match?(%{"account" => _}, &1))
  end

  defp create_account({account_req, data}) do
    account_req
    |> CreateAccount.execute
    |> return_tuple(data)
  end

  defp create_transactions({data, transaction_req}) do
    transaction_req
    |> CreateTransactions.execute
    |> return_tuple(data)

  end

  defp return_tuple(first, second), do: {first, second}
  defp process_response(_result), do: "dada"
end
