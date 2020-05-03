defmodule JeopardyWeb.Presence do
  use Phoenix.Presence,
    otp_app: :jeopardy,
    pubsub_server: Jeopardy.PubSub

  def list_presences(topic) do
    list(topic)
    |> Enum.map(fn {name, _data} ->
      name
    end)
  end
end
