defmodule DemoCCAccountRule.Interface.Controllers.TransactionControllerTest do
  use ExUnit.Case, async: true

  alias DemoCCAccountRule.Interface.Controllers.TransactionController


  describe "create/1" do
    setup do
      account =
        %{
          "account" => %{
            "active-card" => true,
            "available-limit" => 100
          }
        }
      transactions = [
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
        }
      ]

      transactions_with_merchant_missed = [
        %{
          "transaction" => %{
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
        }
      ]

      transactions_with_amount_missed = [
        %{
          "transaction" => %{
            "merchant" => "Burger King",
            "time" => "2019-02-13T11:00:00.000Z"
          }
        },
        %{
          "transaction" => %{
            "merchant" => "Habbib's",
            "amount" => 90,
            "time" => "2019-02-13T11:03:00.000Z"
          }
        }
      ]

      transactions_with_time_missed = [
        %{
          "transaction" => %{
            "merchant" => "Burger King",
            "amount" => 20,
          }
        },
        %{
          "transaction" => %{
            "merchant" => "Habbib's",
            "amount" => 90,
            "time" => "2019-02-13T11:03:00.000Z"
          }
        }
      ]

      transactions_with_merchant_and_time_missed = [
        %{
          "transaction" => %{
            "amount" => 20,
          }
        },
        %{
          "transaction" => %{
            "merchant" => "Habbib's",
            "amount" => 90,
            "time" => "2019-02-13T11:03:00.000Z"
          }
        }
      ]

      transactions_with_merchant_and_amount_missed = [
        %{
          "transaction" => %{
            "time" => "2019-02-13T11:00:00.000Z"
          }
        },
        %{
          "transaction" => %{
            "merchant" => "Habbib's",
            "amount" => 90,
            "time" => "2019-02-13T11:03:00.000Z"
          }
        }
      ]

      right_result = [
        %{
          "after-operation" => 80,
          "before-operation" => 100,
          "transaction" => %{
            "amount" => 20,
            "merchant" => "Burger King",
            "time" => ~U[2019-02-13 11:00:00.000Z]
          }
        },
        %{
          "after-operation" => 80,
          "before-operation" => 80,
          "transaction" => %{
            "amount" => 90,
            "merchant" => "Habbib's",
            "time" => ~U[2019-02-13 11:03:00.000Z]
          },
          "violations" => ["insufficient-limit"]
        }
      ]

      account_not_initialized = [
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
            "amount" => 90,
            "merchant" => "Habbib's",
            "time" => ~U[2019-02-13 11:03:00.000Z]
          },
          "violations" => ["account-not-initialized"]
        }
      ]

      account_already_initialized = [
        %{

          "transaction" => %{
            "amount" => 20,
            "merchant" => "Burger King",
            "time" => ~U[2019-02-13 11:00:00.000Z]
          },
          "violations" => ["account-already-initialized"]
        },
        %{
          "transaction" => %{
            "amount" => 90,
            "merchant" => "Habbib's",
            "time" => ~U[2019-02-13 11:03:00.000Z]
          },
          "violations" => ["account-already-initialized"]
        }
      ]

      account_creation_error = [
        %{

          "transaction" => %{
            "amount" => 20,
            "merchant" => "Burger King",
            "time" => ~U[2019-02-13 11:00:00.000Z]
          },
          "violations" => ["account-creation-error"]
        },
        %{
          "transaction" => %{
            "amount" => 90,
            "merchant" => "Habbib's",
            "time" => ~U[2019-02-13 11:03:00.000Z]
          },
          "violations" => ["account-creation-error"]
        }
      ]

      transaction_creation_error = [
        %{

          "transaction" => %{
            "merchant" => "Burger King",
            "time" => ~U[2019-02-13 11:00:00.000Z]
          },
          "violations" => ["account-creation-error"]
        },
        %{
          "transaction" => %{
            "amount" => 90,
            "merchant" => "Habbib's",
            "time" => ~U[2019-02-13 11:03:00.000Z]
          },
        }
      ]

      transactions_with_time_missed_output = [
        %{
          "transaction" => %{
            "merchant" => "Habbib's",
            "time" => ~U[2019-02-13 11:03:00.000Z],
            "amount" => 90
          },
          "after-operation" => 10,
          "before-operation" => 100
        },
        %{
          "transaction" => %{
            "amount" => 20,
            "merchant" => "Burger King"
          },
          "violations" => ["transaction-missed-time"]
        }
      ]

      transactions_with_merchant_missed_output = [
        %{
          "after-operation" => 10,
          "before-operation" => 100,
          "transaction" => %{
            "amount" => 90,
            "merchant" => "Habbib's",
            "time" => ~U[2019-02-13 11:03:00.000Z]
          }
        },
        %{
          "transaction" => %{
            "amount" => 20,
            "time" => ~U[2019-02-13 11:00:00.000Z]
          },
          "violations" => ["transaction-missed-merchant"]
        }
      ]

      transactions_with_amount_missed_output = [
        %{
          "transaction" => %{
            "time" => ~U[2019-02-13 11:00:00.000Z],
            "merchant" => "Burger King"
          },
          "violations" => ["transaction-missed-amount"]
        },
        %{
          "after-operation" => 10,
          "before-operation" => 100,
          "transaction" => %{
            "amount" => 90,
            "merchant" => "Habbib's",
            "time" => ~U[2019-02-13 11:03:00.000Z]
          }
        }
      ]

      transactions_with_merchant_and_amount_missed_output = [
        %{
          "transaction" => %{
            "time" => ~U[2019-02-13 11:00:00.000Z]
          },
          "violations" => [
            "transaction-missed-merchant",
            "transaction-missed-amount"
          ]
        },
        %{
          "after-operation" => 10,
          "before-operation" => 100,
          "transaction" => %{
            "amount" => 90,
            "merchant" => "Habbib's",
            "time" => ~U[2019-02-13 11:03:00.000Z]
          }
        }
      ]

      transactions_with_merchant_and_time_missed_output = [
        %{
          "after-operation" => 10,
          "before-operation" => 100,
          "transaction" => %{
            "amount" => 90,
            "merchant" => "Habbib's",
            "time" => ~U[2019-02-13 11:03:00.000Z]
          }
        },
        %{
          "transaction" => %{
            "amount" => 20
          },
          "violations" => ["transaction-missed-merchant", "transaction-missed-time"]
        }
      ]

      %{
        account: account,
        transactions: transactions,
        right_result: right_result,
        account_not_initialized: account_not_initialized,
        account_already_initialized: account_already_initialized,
        account_creation_error: account_creation_error,
        transaction_creation_error: transaction_creation_error,
        transactions_with_time_missed: transactions_with_time_missed,
        transactions_with_time_missed_output: transactions_with_time_missed_output,
        transactions_with_merchant_missed: transactions_with_merchant_missed,
        transactions_with_merchant_missed_output: transactions_with_merchant_missed_output,
        transactions_with_amount_missed: transactions_with_amount_missed,
        transactions_with_amount_missed_output: transactions_with_amount_missed_output,
        transactions_with_merchant_and_amount_missed: transactions_with_merchant_and_amount_missed,
        transactions_with_merchant_and_amount_missed_output: transactions_with_merchant_and_amount_missed_output,
        transactions_with_merchant_and_time_missed: transactions_with_merchant_and_time_missed,
        transactions_with_merchant_and_time_missed_output: transactions_with_merchant_and_time_missed_output
      }
    end

    test "given a group of transaction then created", context do
      assert context.right_result == TransactionController.create(context.account, context.transactions)
    end

    test "given a group of transaction then created with account not initialized then return operation with right violation",
         context do
      assert context.account_not_initialized == TransactionController.create(
               :account_not_initialized,
               context.transactions
             )
    end

    test "given a group of transaction with account not initialized then return operation with right violation",
         context do
      assert context.account_not_initialized == TransactionController.create(
               :account_not_initialized,
               context.transactions
             )
    end

    test "given a group of transaction with account already initialized then return operation with right violation",
         context do
      assert context.account_already_initialized == TransactionController.create(
               :account_already_initialized,
               context.transactions
             )
    end

    test "given a group of transaction with account contains error then return it with right violation", context do
      assert context.account_creation_error == TransactionController.create(
               :account_creation_error,
               context.transactions
             )
    end

    test "given a group of transaction with one of them missing time then return the operation with right violation and other transaction applied",
         context do
      assert context.transactions_with_time_missed_output == TransactionController.create(
               context.account,
               context.transactions_with_time_missed
             )
    end

    test "given a group of transaction with one of them missing name then return the operation with right violation and other transaction applied",
         context do
      assert context.transactions_with_merchant_missed_output == TransactionController.create(
               context.account,
               context.transactions_with_merchant_missed
             )
    end

    test "given a group of transaction with one of them missing amount then return the operation with right violation and other transaction applied",
         context do
      assert context.transactions_with_amount_missed_output == TransactionController.create(
               context.account,
               context.transactions_with_amount_missed
             )
    end

    test "given a group of transaction with one of them missing merchant and amount then return the operation with right violation and other transaction applied",
         context do
      assert context.transactions_with_merchant_and_amount_missed_output == TransactionController.create(
               context.account,
               context.transactions_with_merchant_and_amount_missed
             )
    end

    test "given a group of transaction with one of them missing merchant and time then return the operation with right violation and other transaction applied",
         context do
      assert context.transactions_with_merchant_and_time_missed_output == TransactionController.create(
               context.account,
               context.transactions_with_merchant_and_time_missed
             )
    end

  end

end
