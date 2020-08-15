defmodule JeopardyWeb.Accounts.Drafts.GameLive.Edit do
  use JeopardyWeb, :live_view
  alias Jeopardy.Drafts
  require Logger

  @impl true
  def handle_params(%{"id" => id, "round" => round}, _url, socket)
      when round in ~w(details jeopardy double-jeopardy final-jeopardy) do
    IO.inspect(round, label: "[xxx] round")

    {:noreply,
     socket
     |> assign(game: Drafts.get_game!(id))
     |> assign(active_tab: String.replace(round, "-", "_"))}
  end

  @impl true
  def handle_params(%{"id" => id}, url, socket),
    do: handle_params(%{"id" => id, "round" => "details"}, url, socket)
end
