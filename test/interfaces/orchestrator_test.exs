defmodule NuAuthorizer.Interface.OrchestratorTest do
  use ExUnit.Case, async: true

  import Mock

  alias NuAuthorizer.Interface.Orchestrator

  describe "run" do

    setup do
      account = %{
        "account" => %{
          "active-card" => true,
          "available-limit": 100
        }
      }
      input_right = "{\"account\": {\"active-card\": true, \"available-limit\": 100}}\n{\"transaction\": {\"merchant\": \"Burger King\", \"amount\": 20, \"time\":\"2019-02-13T10:00:00.000Z\"}}\n{\"transaction\": {\"merchant\": \"Habbib's\", \"amount\": 90, \"time\":\"2019-02-13T11:00:00.000Z\"}}"
      input_account_already_initialized = "{\"account\": {\"active-card\": true, \"available-limit\": 100}}\n{\"account\":{\"active-card\": true, \"available-limit\": 100}}\n{\"transaction\":{\"merchant\": \"Burger King\",\"amount\":20,\"time\":\"2019-02-13T10:00:00.000Z\"}}"

      input_account_not_initialized = "{\"transaction\":{\"merchant\": \"Burger King\", \"amount\":20,\"time\":\"2019-02-13T10:00:00.000Z\"}}\n{\"transaction\": {\"merchant\": \"Habbib's\", \"amount\": 90, \"time\":\"2019-02-13T11:00:00.000Z\"}}"
      output_account_already_initialized = "{\"account\":{\"active-card\":false,\"available-limit\":\"not-applicable\"},\"violations\":[\"account-already-initialized\"]}"
      result = [
        %{
          "after_operation" => 80,
          "transaction" => %{
            "amount" => 20,
            "merchant" => "Burger King",
            "time" => ~U[2019-02-13 10:00:00.000Z]
          }
        },
        %{
          "after_operation" => 80,
          "transaction" => %{
            "amount" => 90,
            "merchant" => "Habbib's",
            "time" => ~U[2019-02-13 11:00:00.000Z]
          },
          "violations" => ["insufficient-limit"]
        }
      ]
      output_right = "{\"account\":{\"active-card\":true,\"available-limit\":100},\"violations\":[]}\n{\"account\":{\"active-card\":true,\"available-limit\":80},\"violations\":[]}\n{\"account\":{\"active-card\":true,\"available-limit\":80},\"violations\":[\"insufficient-limit\"]}"
      output_account_not_initialized = "{\"account\":{\"active-card\":false,\"available-limit\":\"not-applicable\"},\"violations\":[\"account-not-initialized\"]}\n{\"account\":{\"active-card\":false,\"available-limit\":\"not-applicable\"},\"violations\":[\"account-not-initialized\"]}"
      transactions = [
        %{
          "transaction" => %{
            "merchant" => "Burger King",
            "amount" => 20,
            "time" => "2019-02-13T10:00:00.000Z"
          }
        },
        %{
          "transaction" => %{
            "merchant" => "Habbib's",
            "amount" => 90,
            "time" => "2019-02-13T11:00:00.000Z"
          }
        }
      ]
      %{
        account: account,
        input_right: input_right,
        result: result,
        output_right: output_right,
        transactions: transactions,
        input_account_not_initialized: input_account_not_initialized,
        output_account_not_initialized: output_account_not_initialized,
        input_account_already_initialized: input_account_already_initialized,
        output_account_already_initialized: output_account_already_initialized
      }


    end

    test "given a stream of data then route them to right controller and produce result", context do
      input_right = context.input_right
      output_right = context.output_right

      with_mock IO, [:passthrough], [read: fn (:stdio, :all) -> input_right end] do
        assert output_right == Orchestrator.run()
      end
    end

    test "given a stream of data without account has initialized then route them to right controller and produce result",
         context do
      input_account_not_initialized = context.input_account_not_initialized
      output_account_not_initialized = context.output_account_not_initialized

      with_mock IO, [:passthrough], [read: fn (:stdio, :all) -> input_account_not_initialized end] do
        assert output_account_not_initialized == Orchestrator.run()
      end
    end

    test "given a stream of data with duplicate account then route them to right controller and produce result",
         context do
      input_account_already_initialized = context.input_account_already_initialized
      output_account_already_initialized = context.output_account_already_initialized

      with_mock IO, [:passthrough], [read: fn (:stdio, :all) -> input_account_already_initialized end] do
        assert output_account_already_initialized == Orchestrator.run()
      end
    end

  end
end