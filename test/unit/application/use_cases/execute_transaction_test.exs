defmodule NuAuthorizer.ExecuteTransactionTest do
  use ExUnit.Case

  alias NuAuthorizer.Application.UseCases.ExecuteTransaction
  alias NuAuthorizer.Support.CustomHelpers

  describe "execute/1" do

    test "given a group of valid transactions then execute operation" do
      {transactions, account} = {
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
             ] = ExecuteTransaction.execute(transactions, account)
    end

    test "given a group of transactions with one of them exceed amount balance then execute operations and drop the one" do
      {transactions, account} = {
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
             ] = ExecuteTransaction.execute(transactions, account)
    end

    test "given a group of transactions with two of them are doubled transaction execute one and dropped the second" do
      {transactions, account} = {
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
             ] = ExecuteTransaction.execute(transactions, account)
    end

    test "given a group of transactions with the fourth one happens 2 min after three of others then dropped them" do
      {transactions, account} = {
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
             ] = ExecuteTransaction.execute(transactions, account)
    end

    test "given a group of transactions with the fourth one happens 2 min after three of others and in the same store then dropped them" do
      {transactions, account} = {
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
                 "after_operation" => 28,
                 "transaction" => %{
                   "amount" => 1,
                   "merchant" => "Chaves Store",
                   "time" => ~U[2019-02-13 11:00:03.000Z]
                 },
               },
               %{
                 "after_operation" => 28,
                 "transaction" => %{
                   "amount" => 2,
                   "merchant" => "Chaves Store",
                   "time" => ~U[2019-02-13 11:00:04.000Z]
                 },
                 "violations" => ["high-frequency-small-interval", "doubled-transaction"]
               }
             ] = ExecuteTransaction.execute(transactions, account)
    end

    test "given a group of transactions with the fourth one happens 2 min after three of others and in the same store and overpass card balance limit then dropped them" do
      {transactions, account} = {
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
              "amount" => 900,
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
                 "after_operation" => 28,
                 "transaction" => %{
                   "amount" => 1,
                   "merchant" => "Chaves Store",
                   "time" => ~U[2019-02-13 11:00:03.000Z]
                 },
               },
               %{
                 "after_operation" => 28,
                 "transaction" => %{
                   "amount" => 900,
                   "merchant" => "Chaves Store",
                   "time" => ~U[2019-02-13 11:00:04.000Z]
                 },
                 "violations" => ["high-frequency-small-interval", "doubled-transaction", "insufficient-limit"]
               }
             ] = ExecuteTransaction.execute(transactions, account)
    end

    test "given a group of transactions with the fourth one happens 2 min after three of others and in the same store and two of them overpass card balance limit then dropped them" do
      {transactions, account} = {
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
              "amount" => 100,
              "time" => CustomHelpers.to_datetime("2019-02-13T11:00:03.000Z")
            }
          },
          %{
            "transaction" => %{
              "merchant" => "Chaves Store",
              "amount" => 900,
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
                 "after_operation" => 29,
                 "transaction" => %{
                   "amount" => 100,
                   "merchant" => "Chaves Store",
                   "time" => ~U[2019-02-13 11:00:03.000Z]
                 },
                 "violations" => ["insufficient-limit"]
               },
               %{
                 "after_operation" => 29,
                 "transaction" => %{
                   "amount" => 900,
                   "merchant" => "Chaves Store",
                   "time" => ~U[2019-02-13 11:00:04.000Z]
                 },
                 "violations" => ["high-frequency-small-interval", "doubled-transaction", "insufficient-limit"]
               }
             ] = ExecuteTransaction.execute(transactions, account)
    end

    test "given a group of transactions with the third one happens after 2 min after second nd in the same store and one of them overpass card balance limit then accept first and fourth dropped others" do
      {transactions, account} = {
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
              "amount" => 60,
              "time" => CustomHelpers.to_datetime("2019-02-13T11:00:02.000Z")
            }
          },
          %{
            "transaction" => %{
              "merchant" => "Habbib's",
              "amount" => 70,
              "time" => CustomHelpers.to_datetime("2019-02-13T11:00:03.000Z")
            }
          },
          %{
            "transaction" => %{
              "merchant" => "Chaves Store",
              "amount" => 80,
              "time" => CustomHelpers.to_datetime("2019-02-13T12:00:04.000Z")
            }
          }
        ],
        %{
          "account" => %{
            "active-card" => true,
            "available-limit" => 200
          }
        }
      }

      assert [
               %{
                 "after_operation" => 180,
                 "transaction" => %{
                   "amount" => 20,
                   "merchant" => "Burger King",
                   "time" => ~U[2019-02-13 11:00:00.000Z]
                 }
               },
               %{
                 "after_operation" => 120,
                 "transaction" => %{
                   "amount" => 60,
                   "merchant" => "Habbib's",
                   "time" => ~U[2019-02-13 11:00:02.000Z]
                 }
               },
               %{
                 "after_operation" => 120,
                 "transaction" => %{
                   "amount" => 70,
                   "merchant" => "Habbib's",
                   "time" => ~U[2019-02-13 11:00:03.000Z]
                 },
                 "violations" => ["doubled-transaction"]
               },
               %{
                 "after_operation" => 40,
                 "transaction" => %{
                   "amount" => 80,
                   "merchant" => "Chaves Store",
                   "time" => ~U[2019-02-13 12:00:04.000Z]
                 },
               }
             ] = ExecuteTransaction.execute(transactions, account)
    end

    test "given a account with no balance and a group of transactions then dropped all" do
      {transactions, account} = {
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
              "amount" => 60,
              "time" => CustomHelpers.to_datetime("2019-02-13T11:00:02.000Z")
            }
          }
        ],
        %{
          "account" => %{
            "active-card" => true,
            "available-limit" => 0
          }
        }
      }

      assert [
               %{
                 "after_operation" => 0,
                 "transaction" => %{
                   "amount" => 20,
                   "merchant" => "Burger King",
                   "time" => ~U[2019-02-13 11:00:00.000Z]
                 },
                 "violations" => ["insufficient-limit"]
               },
               %{
                 "after_operation" => 0,
                 "transaction" => %{
                   "amount" => 60,
                   "merchant" => "Habbib's",
                   "time" => ~U[2019-02-13 11:00:02.000Z]
                 },
                 "violations" => ["insufficient-limit"]
               }
             ] = ExecuteTransaction.execute(transactions, account)
    end

    test "given a account with no card active and a group of transactions then dropped all" do
      {transactions, account} = {
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
              "amount" => 60,
              "time" => CustomHelpers.to_datetime("2019-02-13T11:00:02.000Z")
            }
          }
        ],
        %{
          "account" => %{
            "active-card" => false,
            "available-limit" => 0
          }
        }
      }

      assert [
               %{
                 "transaction" => %{
                   "amount" => 20,
                   "merchant" => "Burger King",
                   "time" => ~U[2019-02-13 11:00:00.000Z]
                 },
                 "violations" => ["card-not-active"]
               },
               %{
                 "transaction" => %{
                   "amount" => 60,
                   "merchant" => "Habbib's",
                   "time" => ~U[2019-02-13 11:00:02.000Z]
                 },
                 "violations" => ["card-not-active"]
               }
             ] = ExecuteTransaction.execute(transactions, account)
    end

    test "given a account no initialized and a group of transactions then dropped all" do
      {transactions, account} = {
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
              "amount" => 60,
              "time" => CustomHelpers.to_datetime("2019-02-13T11:00:02.000Z")
            }
          }
        ],
        %{
          "account" => :account_not_initialized
        }
      }

      assert [
               %{
                 "transaction" => %{
                   "amount" => 20,
                   "merchant" => "Burger King",
                   "time" => ~U[2019-02-13 11:00:00.000Z]
                 },
                 "violations" => ["account-not-initialized"]
               },
               %{
                 "transaction" => %{
                   "amount" => 60,
                   "merchant" => "Habbib's",
                   "time" => ~U[2019-02-13 11:00:02.000Z]
                 },
                 "violations" => ["account-not-initialized"]
               }
             ] = ExecuteTransaction.execute(transactions, account)
    end

  end

end
