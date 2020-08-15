defmodule JeopardyWeb.Accounts.Drafts.GameLive.Edit do
  use JeopardyWeb, :live_view
  alias Jeopardy.Drafts
  alias Jeopardy.Drafts.Game
  require Logger

  @impl true
  def handle_params(%{"id" => id, "round" => round}, _url, socket)
      when round in ~w(details jeopardy double-jeopardy final-jeopardy) do
    IO.inspect(round, label: "[xxx] round")

    round = String.replace(round, "-", "_")
    game = Drafts.get_game!(id)
    toc_links = toc_links_for_round(game, round)
    fj_clue = Map.get(game.clues, "final_jeopardy")

    cs = %{
      details: Drafts.change_game(game),
      final_jeopardy: Drafts.change_final_jeopardy_clue(%{}, fj_clue)
    }

    {:noreply,
     socket
     |> assign(game: game)
     |> assign(toc_links: toc_links)
     |> assign(cs: cs)
     |> assign(active_tab: round)}
  end

  @impl true
  def handle_params(%{"id" => id}, url, socket),
    do: handle_params(%{"id" => id, "round" => "details"}, url, socket)

  defp toc_links_for_round(%Game{} = game, round) do
    case round do
      "details" -> [%{link: "general_info", text: "General Info"}]
      "jeopardy" -> toc_categories(game, round)
      "double_jeopardy" -> toc_categories(game, round)
      "final_jeopardy" -> [%{link: "category", text: "Category"}, %{link: "clue", text: "Clue"}]
    end
  end

  defp toc_categories(%Game{} = game, round) when round in ~w(jeopardy double_jeopardy),
    do:
      game.clues[round]
      |> Enum.with_index()
      |> Enum.map(fn {cat, i} ->
        %{link: "category_#{i + 1}", text: cat["category"] || "Category #{i + 1}"}
      end)
end
