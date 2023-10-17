defmodule Jeopardy.Timers do
  @moduledoc """
    Utility context to calculate time remaining
  """

  @doc """
    Calculate the time remaining in milliseconds, given an expiration
  """
  @spec time_remaining(expires_at :: DateTime.t() | nil) :: non_neg_integer() | nil
  def time_remaining(%DateTime{} = expires_at) do
    expires_at |> DateTime.diff(DateTime.utc_now(), :millisecond) |> max(0)
  end

  def time_remaining(nil), do: nil

  @doc """
    Returns a `DateTime` a given number of seconds in the future.
  """
  @spec add(seconds :: non_neg_integer()) :: DateTime.t()
  def add(seconds) do
    DateTime.add(DateTime.utc_now(), seconds, :second)
  end
end
