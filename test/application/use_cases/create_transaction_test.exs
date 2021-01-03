defmodule NuAuthorizer.CreateTransactionTest do
  use ExUnit.Case, async: true

  alias NuAuthorizer.Application.UseCases.CreateTransactions

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
      assert [
               %{
                 "transaction" => %{
                   "amount" => 20,
                   "merchant" => "Burger King",
                   "time" => ~U[2019-02-13 11:00:00.000Z]
                 }
               },
               %{
                 "transaction" => %{
                   "amount" => 90,
                   "merchant" => "Habbib's",
                   "time" => ~U[2019-02-13 11:03:00.000Z]
                 }
               },
               %{
                 "transaction" => %{
                   "amount" => 90,
                   "merchant" => "Habbib's",
                   "time" => ~U[2019-02-13 11:02:00.000Z]
                 }
               },
               %{
                 "transaction" => %{
                   "amount" => 90,
                   "merchant" => "Shell",
                   "time" => ~U[2019-02-13 11:01:00.000Z]
                 }
               },
               %{
                 "transaction" => %{
                   "amount" => 90,
                   "merchant" => "Ipiranga",
                   "time" => ~U[2019-02-13 11:01:01.000Z]
                 }
               },
               %{
                 "transaction" => %{
                   "amount" => 90,
                   "merchant" => "Ipiranga",
                   "time" => ~U[2019-02-13 11:01:01.002Z]
                 }
               },
               %{
                 "transaction" => %{
                   "amount" => 5,
                   "merchant" => "Ipiranga",
                   "time" => ~U[2020-02-13 11:01:01.002Z]
                 }
               },
               %{
                 "transaction" => %{
                   "amount" => 200,
                   "merchant" => "Xevron",
                   "time" => ~U[2020-02-13 20:01:01.002Z]
                 }
               }
             ] == CreateTransactions.execute(data)
    end

    test "given a group of transaction with invalid parameter then drop operation" do
      data = [
        %{
          "transaction" => %{
            "xxx" => "Burger King",
            "amount" => 20,
            "time" => "2019-02-13T11:00:00.000Z"
          }
        },
      ]
      assert [%{"transaction" => %{"amount" => 20, "time" => ~U[2019-02-13 11:00:00.000Z]}, "violations" => ["transaction-missed-merchant"]}] == CreateTransactions.execute(data)
    end

    test "given a group of transaction and a unknown error happens then drop operation" do
      assert :transaction_unknown_error == CreateTransactions.execute(:error)
    end
  end

end
