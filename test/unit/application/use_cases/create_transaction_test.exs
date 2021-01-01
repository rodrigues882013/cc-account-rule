defmodule NuAuthorizer.CreateTransactionTest do
  use ExUnit.Case

  alias NuAuthorizer.Application.UseCases.CreateTransactions
  alias NuAuthorizer.Domain.Transaction

  import Mock

  describe "execute/1" do
    setup do
      data = [
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
      %{data: data}
    end

    test "given a group of transaction then created", context do
      data = context.data
      assert _data = CreateTransactions.execute(data)
    end

    test "given a group of transaction with invalid parameter then drop operation", context do
      [head | _] = context.data

      with_mock Transaction, [create: fn (_) -> :invalid_parameter end] do
        assert transaction_creation_error = CreateTransactions.execute([head])
      end
    end

    test "given a group of transaction and a unknown error happens then drop operation", context do
      [head | _] = context.data

      with_mock Transaction, [create: fn (_) -> :error end] do
        assert transaction_unknown_error = CreateTransactions.execute([head])
      end
    end
  end

end
