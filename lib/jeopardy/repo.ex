defmodule Jeopardy.Repo do
  use Ecto.Repo,
    otp_app: :jeopardy,
    adapter: Ecto.Adapters.Postgres

  def update_all_ts(queryable, updates, opts \\ []) do
    update_all(
      queryable,
      Enum.map(updates, fn {a, b} = c ->
        if a == :set, do: {:set, b ++ [updated_at: DateTime.utc_now]}, else: c
      end),
      opts
    )
  end

  def insert_all(schema_or_source, entries, opts, :with_timestamps) do
    insert_all(
      schema_or_source,
      Enum.map(entries, &inject_timestamps/1),
      opts
    )
  end

  defp inject_timestamps(m) do
    time = DateTime.utc_now |> DateTime.truncate(:second)
    m |> Map.merge(%{inserted_at: time, updated_at: time})
    end
end
