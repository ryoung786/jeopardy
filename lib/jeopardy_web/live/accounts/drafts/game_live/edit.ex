defmodule JeopardyWeb.Accounts.Drafts.GameLive.Edit do
  use JeopardyWeb, :live_view
  alias Jeopardy.Drafts
  alias Jeopardy.Drafts.Game
  require Logger

  @impl true
  def handle_params(%{"id" => id, "round" => round}, _url, socket)
      when round in ~w(details jeopardy double-jeopardy final-jeopardy) do
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

  @impl true
  def handle_event("validate-details", %{"details" => params}, socket) do
    params =
      Map.update!(
        params,
        "tags",
        fn str -> String.split(str, ",", trim: true) |> Enum.map(&String.trim/1) end
      )

    cs =
      Map.replace!(
        socket.assigns.cs,
        :details,
        socket.assigns.game
        |> Drafts.change_game(params)
        |> Map.put(:action, :validate)
      )

    {:noreply, assign(socket, cs: cs)}
  end

  @impl true
  def handle_event("blur-details", %{"field" => field, "value" => val}, socket) do
    params =
      case field do
        "tags" -> %{field => String.split(val, ",", trim: true) |> Enum.map(&String.trim/1)}
        _ -> %{field => val}
      end

    case Drafts.update_game(socket.assigns.game, params) do
      {:ok, game} ->
        {:noreply,
         assign(socket, game: game, cs: %{socket.assigns.cs | details: Drafts.change_game(game)})}

      {:error, cs} ->
        {:noreply, assign(socket, cs: %{socket.assigns.cs | details: cs})}
    end
  end

  @impl true
  def handle_event("validate-jeopardy", %{"jeopardy" => params}, socket) do
    IO.inspect(params, label: "[xxx] validate jeopardy params")
    cs = socket.assigns.cs
    {:noreply, assign(socket, cs: cs)}
  end

  @impl true
  def handle_event("validate-final-jeopardy", %{"final_jeopardy" => params}, socket) do
    cs =
      Map.replace!(
        socket.assigns.cs,
        :final_jeopardy,
        socket.assigns.game
        |> Drafts.change_final_jeopardy_clue(params)
        |> Map.put(:action, :validate)
      )

    {:noreply, assign(socket, cs: cs)}
  end

  @impl true
  def handle_event("blur-final-jeopardy", %{"field" => field, "value" => val}, socket) do
    params = %{field => val}

    case Drafts.update_final_jeopardy_clue(socket.assigns.game, params) do
      {:ok, game} ->
        {:noreply,
         assign(socket, game: game, cs: %{socket.assigns.cs | details: Drafts.change_game(game)})}

      {:error, cs} ->
        {:noreply, assign(socket, cs: %{socket.assigns.cs | details: cs})}
    end
  end

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
