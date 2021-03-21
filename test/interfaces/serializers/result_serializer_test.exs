defmodule DemoCCAccountRule.Interface.Serializers.ResultSerializerTest do
  use ExUnit.Case, async: true

  alias DemoCCAccountRule.Interface.Serializers.ResultSerializer

  describe "run" do
    setup do
      account = %{
        "account" => %{
          "active-card" => true,
          "available-limit" => 100
        }
      }
      input = [
        %{
          "after-operation" => 80,
          "before-operation" => 100,
          "transaction" => %{
            "amount" => 20,
            "merchant" => "Burger King",
            "time" => ~U[2019-02-13 10:00:00.000Z]
          }
        },
        %{
          "after-operation" => 80,
          "before-operation" => 80,
          "transaction" => %{
            "amount" => 90,
            "merchant" => "Habbib's",
            "time" => ~U[2019-02-13 11:00:00.000Z]
          },
          "violations" => ["insufficient-limit"]
        }
      ]

      input_not_initialized = [
        %{
          "transaction" => %{
            "amount" => 20,
            "merchant" => "Burger King",
            "time" => ~U[2019-02-13 10:00:00.000Z]
          },
          "violations" => ["account-not-initialized"]

        },
        %{
          "transaction" => %{
            "amount" => 90,
            "merchant" => "Habbib's",
            "time" => ~U[2019-02-13 11:00:00.000Z]
          },
          "violations" => ["account-not-initialized"]
        }
      ]

      input_already_initialized = [
        %{
          "transaction" => %{
            "amount" => 20,
            "merchant" => "Burger King",
            "time" => ~U[2019-02-13 10:00:00.000Z]
          },
          "violations" => ["account-already-initialized"]

        },
        %{
          "transaction" => %{
            "amount" => 90,
            "merchant" => "Habbib's",
            "time" => ~U[2019-02-13 11:00:00.000Z]
          },
          "violations" => ["account-already-initialized"]
        }
      ]
      output_account_not_initialized = "{\"account\":{\"active-card\":false,\"available-limit\":\"not-applicable\"},\"violations\":[\"account-not-initialized\"]}\n{\"account\":{\"active-card\":false,\"available-limit\":\"not-applicable\"},\"violations\":[\"account-not-initialized\"]}"
      output_account_already_initialized = "{\"account\":{\"active-card\":false,\"available-limit\":\"not-applicable\"},\"violations\":[\"account-already-initialized\"]}\n{\"account\":{\"active-card\":false,\"available-limit\":\"not-applicable\"},\"violations\":[\"account-already-initialized\"]}"

      output = "{\"account\":{\"active-card\":true,\"available-limit\":100},\"violations\":[]}\n{\"account\":{\"active-card\":true,\"available-limit\":80},\"violations\":[]}\n{\"account\":{\"active-card\":true,\"available-limit\":80},\"violations\":[\"insufficient-limit\"]}"
      %{
        account: account,
        input: input,
        output: output,
        output_account_not_initialized: output_account_not_initialized,
        output_account_already_initialized: output_account_already_initialized,
        input_not_initialized: input_not_initialized,
        input_already_initialized: input_already_initialized
      }
    end

    test "given a right result then serialize it", context do
      assert context.output == ResultSerializer.serialize({context.account, context.input})
    end

    test "given a result with not initialized account then serialize it", context do
      assert context.output_account_not_initialized == ResultSerializer.serialize(
               {:account_not_initialized, context.input_not_initialized}
             )
    end

    test "given a result with already initialized account then serialize it", context do
      assert context.output_account_already_initialized == ResultSerializer.serialize(
               {:account_already_initialized, context.input_already_initialized}
             )
    end
  end
end
