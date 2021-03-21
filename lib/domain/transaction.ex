defmodule  DemoCCAccountRule.Domain.Transaction do
  @behaviour DemoCCAccountRule.Domain.Behaviours.Transaction

  @impl DemoCCAccountRule.Domain.Behaviours.Transaction
  def create(
        %{
          "transaction" => %{
            "amount" => amount,
            "merchant" => merchant,
            "time" => time
          }
        }
      ) do
    {
      :ok,
      %{
        "transaction" => %{
          "amount" => amount,
          "merchant" => merchant,
          "time" => to_datetime(time)
        }
      }
    }
  end

  @impl DemoCCAccountRule.Domain.Behaviours.Transaction
  def create(
        %{
          "transaction" => %{
            "amount" => amount,
            "merchant" => merchant,
          }
        }
      ) do
    {
      :transaction_invalid_parameter,
      %{
        "transaction" => %{
          "amount" => amount,
          "merchant" => merchant,
        },
        "violations" => ["transaction-missed-time"],
      }
    }
  end

  @impl DemoCCAccountRule.Domain.Behaviours.Transaction
  def create(
        %{
          "transaction" => %{
            "amount" => amount,
            "time" => time
          }
        }
      ) do
    {
      :transaction_invalid_parameter,
      %{
        "transaction" => %{
          "amount" => amount,
          "time" => to_datetime(time),
        },
        "violations" => ["transaction-missed-merchant"],
      }
    }
  end

  @impl DemoCCAccountRule.Domain.Behaviours.Transaction
  def create(
        %{
          "transaction" => %{
            "merchant" => merchant,
            "time" => time
          }
        }
      ) do
    {
      :transaction_invalid_parameter,
      %{
        "transaction" => %{
          "merchant" => merchant,
          "time" => to_datetime(time),
        },
        "violations" => ["transaction-missed-amount"]
      }
    }
  end

  @impl DemoCCAccountRule.Domain.Behaviours.Transaction
  def create(
        %{
          "transaction" => %{
            "time" => time
          }
        }
      ) do
    {
      :transaction_invalid_parameter,
      %{
        "transaction" => %{
          "time" => to_datetime(time),
        },
        "violations" => ["transaction-missed-merchant", "transaction-missed-amount"],
      }
    }
  end

  @impl DemoCCAccountRule.Domain.Behaviours.Transaction
  def create(
        %{
          "transaction" => %{
            "amount" => amount
          }
        }
      ) do
    {
      :transaction_invalid_parameter,
      %{
        "transaction" => %{
          "amount" => amount,
        },
        "violations" => ["transaction-missed-merchant", "transaction-missed-time"],
      }
    }
  end

  @impl DemoCCAccountRule.Domain.Behaviours.Transaction
  def create(
        %{
          "transaction" => %{
          }
        }
      ) do
    {
      :transaction_invalid_parameter,
      %{
        "transaction" => %{},
        "violations" => ["transaction-missed-time", "transaction-missed-merchant", "transaction-missed-amount"],
      }
    }
  end

  @impl DemoCCAccountRule.Domain.Behaviours.Transaction
  def create(_) do
    :error
  end

  defp to_datetime(value) do
    {:ok, datetime, 0} = DateTime.from_iso8601(value)
    datetime
  end
end
