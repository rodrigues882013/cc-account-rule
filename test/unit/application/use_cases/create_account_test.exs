defmodule NuAuthorizer.CreateAccountTest do
  use ExUnit.Case

  alias NuAuthorizer.Application.UseCases.CreateAccount
  alias NuAuthorizer.Domain.Account

  import Mock

  describe "execute/1" do
    setup do
      data = [%{
        "account" => %{
            "active-card" =>  true,
            "available-limit" => 100
        }
      }]
      %{data: data}
    end

    test "given an active card and limit available then create account", context do
      data = context.data

      with_mock Account, [create: fn (_) -> {:ok, data} end] do
        assert _data = CreateAccount.execute(data)
      end

    end

    test "given an inactive card and limit available then create account", context do
      data = context.data

      with_mock Account, [create: fn (_) -> {:ok, data} end] do
        assert _data = CreateAccount.execute(data)
      end
    end

    test "given a valid account then not create account", context do
      data = context.data

      with_mock Account, [create: fn (_) -> :error end] do
        assert :account_unknown_error = CreateAccount.execute(data)
      end
    end

    test "given two accounts then drop operation and not create account", context do
      data = context.data
      assert :account_already_initialized = CreateAccount.execute([data, data])
    end
  end
end
