defmodule NuAuthorizer.ExecuteTransactionTest do
  use ExUnit.Case

  alias NuAuthorizer.Application.UseCases.ExecuteTransaction
  alias NuAuthorizer.Support.CustomHelpers

  describe "execute/1" do

    test "given a group of valid transactions then execute operation" do
      data = {
        [
          %{
            "transaction" => %{
              "merchant" => "Burger King",
              "amount" => 20,
              "time" => CustomHelpers.to_datetime("2019-02-13T11:00:00.000Z")
            }
          },
          %{
            "transaction" => %{
              "merchant" => "Habbib's",
              "amount" => 30,
              "time" => CustomHelpers.to_datetime("2019-02-13T11:03:00.000Z")
              }
          },
          %{
            "transaction" => %{
              "merchant" => "Posto Ipiranga",
              "amount" => 30,
              "time" => CustomHelpers.to_datetime("2019-02-13T11:04:00.000Z")
            }
          }
        ],
        %{
          "account" => %{
            "active-card" => true,
            "available-limit" => 100
          }
        }
      }

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
                   "amount" => 30,
                   "merchant" => "Habbib's",
                   "time" => ~U[2019-02-13 11:03:00.000Z]
                 }
               },
               %{
                 "transaction" => %{
                   "amount" => 30,
                   "merchant" => "Posto Ipiranga",
                   "time" => ~U[2019-02-13 11:04:00.000Z]
                 }
               }
             ] = ExecuteTransaction.execute(data)
    end

    test "given a group of transactions which one of them exceed amount balance then execute operations and drop the one" do
      data = {
        [
          %{
            "transaction" => %{
              "merchant" => "Burger King",
              "amount" => 20,
              "time" => CustomHelpers.to_datetime("2019-02-13T11:00:00.000Z")
            }
          },
          %{
            "transaction" => %{
              "merchant" => "Habbib's",
              "amount" => 30,
              "time" => CustomHelpers.to_datetime("2019-02-13T11:15:00.000Z")
            }
          },
          %{
            "transaction" => %{
              "merchant" => "Posto Ipiranga",
              "amount" => 30,
              "time" => CustomHelpers.to_datetime("2019-02-13T11:20:00.000Z")
            }
          }
        ],
        %{
          "account" => %{
            "active-card" => true,
            "available-limit" => 50
          }
        }
      }

      assert [
               %{
                 "after_operation" => 30,
                 "transaction" => %{
                   "amount" => 20,
                   "merchant" => "Burger King",
                   "time" => ~U[2019-02-13 11:00:00.000Z]
                 }
               },
               %{
                 "after_operation" => 0,
                 "transaction" => %{
                   "amount" => 30,
                   "merchant" => "Habbib's",
                   "time" => ~U[2019-02-13 11:15:00.000Z]
                 }
               },
               %{
                 "after_operation" => 0,
                 "transaction" => %{
                   "amount" => 30,
                   "merchant" => "Posto Ipiranga",
                   "time" => ~U[2019-02-13 11:20:00.000Z]
                 },
                 "violations" => ["insufficient-limit"]
               }
             ] = ExecuteTransaction.execute(data)
    end

    test "given a group of transactions which two of them are doubled transaction execute one and dropped the second" do
      data = {
        [
          %{
            "transaction" => %{
              "merchant" => "Burger King",
              "amount" => 20,
              "time" => CustomHelpers.to_datetime("2019-02-13T11:00:00.000Z")
            }
          },
          %{
            "transaction" => %{
              "merchant" => "Habbib's",
              "amount" => 1,
              "time" => CustomHelpers.to_datetime("2019-02-13T11:03:00.000Z")
            }
          },
          %{
            "transaction" => %{
              "merchant" => "Habbib's",
              "amount" => 1,
              "time" => CustomHelpers.to_datetime("2019-02-13T11:04:00.000Z")
            }
          }
        ],
        %{
          "account" => %{
            "active-card" => true,
            "available-limit" => 50
          }
        }
      }

      assert [
               %{
                 "after_operation" => 30,
                 "transaction" => %{
                   "amount" => 20,
                   "merchant" => "Burger King",
                   "time" => ~U[2019-02-13 11:00:00.000Z]
                 }
               },
               %{
                 "after_operation" => 29,
                 "transaction" => %{
                   "amount" => 1,
                   "merchant" => "Habbib's",
                   "time" => ~U[2019-02-13 11:03:00.000Z]
                 }
               },
               %{
                 "transaction" => %{
                   "amount" => 1,
                   "merchant" => "Habbib's",
                   "time" => ~U[2019-02-13 11:04:00.000Z]
                 },
                 "violations" => ["doubled-transaction"]
               }
             ] = ExecuteTransaction.execute(data)
    end

    test "given a group of transactions which the fourth one happens in 3 min after three of others then dropped them" do
      data = {
        [
          %{
            "transaction" => %{
              "merchant" => "Burger King",
              "amount" => 20,
              "time" => CustomHelpers.to_datetime("2019-02-13T11:00:00.000Z")
            }
          },
          %{
            "transaction" => %{
              "merchant" => "Habbib's",
              "amount" => 1,
              "time" => CustomHelpers.to_datetime("2019-02-13T11:00:02.000Z")
            }
          },
          %{
            "transaction" => %{
              "merchant" => "Chaves Store",
              "amount" => 1,
              "time" => CustomHelpers.to_datetime("2019-02-13T11:00:03.000Z")
            }
          },
          %{
            "transaction" => %{
              "merchant" => "Solar prado",
              "amount" => 1,
              "time" => CustomHelpers.to_datetime("2019-02-13T11:00:04.000Z")
            }
          }
        ],
        %{
          "account" => %{
            "active-card" => true,
            "available-limit" => 50
          }
        }
      }

      assert [
               %{
                 "after_operation" => 30,
                 "transaction" => %{
                   "amount" => 20,
                   "merchant" => "Burger King",
                   "time" => ~U[2019-02-13 11:00:00.000Z]
                 }
               },
               %{
                 "after_operation" => 29,
                 "transaction" => %{
                   "amount" => 1,
                   "merchant" => "Habbib's",
                   "time" => ~U[2019-02-13 11:00:02.000Z]
                 }
               },
               %{
                 "transaction" => %{
                   "amount" => 1,
                   "merchant" => "Chaves Store",
                   "time" => ~U[2019-02-13 11:00:03.000Z]
                 },
               },
               %{
                 "transaction" => %{
                   "amount" => 1,
                   "merchant" => "Solar prado",
                   "time" => ~U[2019-02-13 11:00:04.000Z]
                 },
                 "violations" => ["high-frequency-small-interval"]
               }
             ] = ExecuteTransaction.execute(data)
    end

    test "given a group of transactions which the fourth one happens in 3 min after three of others and in the same store then dropped them" do
      data = {
        [
          %{
            "transaction" => %{
              "merchant" => "Burger King",
              "amount" => 20,
              "time" => CustomHelpers.to_datetime("2019-02-13T11:00:00.000Z")
            }
          },
          %{
            "transaction" => %{
              "merchant" => "Habbib's",
              "amount" => 1,
              "time" => CustomHelpers.to_datetime("2019-02-13T11:00:02.000Z")
            }
          },
          %{
            "transaction" => %{
              "merchant" => "Chaves Store",
              "amount" => 1,
              "time" => CustomHelpers.to_datetime("2019-02-13T11:00:03.000Z")
            }
          },
          %{
            "transaction" => %{
              "merchant" => "Chaves Store",
              "amount" => 2,
              "time" => CustomHelpers.to_datetime("2019-02-13T11:00:04.000Z")
            }
          }
        ],
        %{
          "account" => %{
            "active-card" => true,
            "available-limit" => 50
          }
        }
      }

      assert [
               %{
                 "after_operation" => 30,
                 "transaction" => %{
                   "amount" => 20,
                   "merchant" => "Burger King",
                   "time" => ~U[2019-02-13 11:00:00.000Z]
                 }
               },
               %{
                 "after_operation" => 29,
                 "transaction" => %{
                   "amount" => 1,
                   "merchant" => "Habbib's",
                   "time" => ~U[2019-02-13 11:00:02.000Z]
                 }
               },
               %{
                 "transaction" => %{
                   "amount" => 1,
                   "merchant" => "Chaves Store",
                   "time" => ~U[2019-02-13 11:00:03.000Z]
                 },
               },
               %{
                 "transaction" => %{
                   "amount" => 1,
                   "merchant" => "Solar prado",
                   "time" => ~U[2019-02-13 11:00:04.000Z]
                 },
                 "violations" => ["high-frequency-small-interval", "doubled-transaction"]
               }
             ] = ExecuteTransaction.execute(data)
    end

  end

end
