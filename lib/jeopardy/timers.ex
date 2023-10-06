defmodule Jeopardy.Timers do
  @moduledoc """
    Utility context to calculate time remaining
  """

  @doc """
    Calculate the time remaining in milliseconds, given an expiration
  """
  @spec time_remaining(expires_at :: DateTime.t() | nil) :: non_neg_integer() | nil
  def time_remaining(%DateTime{} = expires_at) do
    DateTime.diff(expires_at, DateTime.utc_now(), :millisecond) |> max(0)
  end

  def time_remaining(nil), do: nil

  @spec add(seconds :: non_neg_integer()) :: DateTime.t()
  def add(seconds) do
    DateTime.utc_now() |> DateTime.add(seconds, :second)
  end
end
