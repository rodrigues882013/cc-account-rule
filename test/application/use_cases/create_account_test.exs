defmodule NuAuthorizer.CreateAccountTest do
  use ExUnit.Case, async: true

  alias NuAuthorizer.Application.UseCases.CreateAccount

  describe "execute/1" do
    setup do
      data = [
        %{
          "account" => %{
            "active-card" =>  true,
            "available-limit" => 100
        }
        }
      ]
      %{data: data}
    end

    test "given an active card and limit available then create account", context do
      data = context.data
      assert Enum.at(data, 0) == CreateAccount.execute(data)

    end

    test "given an inactive card and limit available then create account", context do
      data = context.data
      assert Enum.at(data, 0) == CreateAccount.execute(data)
    end

    test "given a valid account then not create account" do
      assert :account_creation_error == CreateAccount.execute([%{"account" => %{}}])
    end

    test "given two accounts then drop operation and not create account", context do
      data = context.data
      assert :account_already_initialized == CreateAccount.execute([data, data])
    end
  end
end
