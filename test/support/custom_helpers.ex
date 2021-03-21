defmodule DemoCCAccountRule.Support.CustomHelpers do
  def equal_list(list1, list2) do
    list1 -- list2 == list2 -- list1
  end

  def to_datetime(value) do
    {:ok, datetime, 0} = DateTime.from_iso8601(value)
    datetime
  end
end
