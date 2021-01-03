defmodule NuAuthorizer.Interface.Controllers.AccountControllerTest do
  use ExUnit.Case, async: true

  alias NuAuthorizer.Interface.Controllers.AccountController


  describe "create/1" do
    setup do
      account_req = [
        %{
          "account" => %{
            "active-card" =>  true,
            "available-limit" => 100
          }
        }
      ]
      %{account_req: account_req}

    end

    test "given a account request then create an account", context do
      assert Enum.at(context.account_req, 0) == AccountController.create(context.account_req)
    end

    test "given a account request with more than one account then not initialized account and return an error", context do
      assert :account_already_initialized == AccountController.create(context.account_req ++ [%{}])
    end

    test "given a account request with none account then not initialized account and return an error" do
      assert :account_not_initialized == AccountController.create([])
    end

    test "given a account request with wrong parameters then not initialized account and return an error" do
      assert :account_creation_error == AccountController.create([%{"account" => %{}}])
    end
  end

end
