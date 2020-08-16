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

    cs = all_changesets(game)

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
  def handle_event("validate-category", %{"category" => params}, socket) do
    id = String.to_integer(params["id"])
    round = String.to_atom(params["round"])
    new_cs = Drafts.change_category(%{}, params) |> Map.put(:action, :validate)

    %{assigns: %{cs: cs}} =
      update_in(socket.assigns.cs[round][:categories], &List.replace_at(&1, id, new_cs))

    {:noreply, assign(socket, cs: cs)}
  end

  @impl true
  def handle_event("validate-clue", %{"clue" => params}, socket) do
    id = String.to_integer(params["id"])
    round = String.to_atom(params["round"])
    clue = Drafts.get_clue!(socket.assigns.game, id)
    new_cs = Drafts.change_clue(clue, params) |> Map.put(:action, :validate)

    IO.inspect(params, label: "[xxx] clue params")
    IO.inspect(new_cs, label: "[xxx] clue cs")
    %{assigns: %{cs: cs}} = put_in(socket.assigns.cs[round][:clues][id], new_cs)

    {:noreply, assign(socket, cs: cs)}
  end

  @impl true
  def handle_event("blur-category", %{"round" => round, "id" => id, "value" => val}, socket) do
    id = String.to_integer(id)
    id = if round == "jeopardy", do: id, else: id + 6
    params = %{category: val}

    case Drafts.update_category(socket.assigns.game, id, %{}, params) do
      {:ok, game} ->
        {:noreply,
         assign(socket,
           game: game,
           toc_links: toc_links_for_round(game, round),
           cs: all_changesets(game)
         )}

      {:error, cs} ->
        %{assigns: %{cs: all}} =
          update_in(socket.assigns.cs[round][:categories], &List.replace_at(&1, id, cs))

        {:noreply, assign(socket, cs: all)}
    end
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

  def generate_category_changesets(game, round) do
    Map.get(game.clues, Atom.to_string(round))
    |> Enum.map(fn c ->
      Drafts.change_category(%{}, %{category: c["category"]})
    end)
  end

  def generate_clue_changesets(game, round) do
    Map.get(game.clues, Atom.to_string(round))
    |> Enum.reduce(%{}, fn c, acc ->
      cs_map =
        c["clues"]
        |> Enum.reduce(%{}, fn clue, acc2 ->
          Map.merge(acc2, %{clue["id"] => Drafts.change_clue(%{}, clue)})
        end)

      Map.merge(acc, cs_map)
    end)
  end

  defp all_changesets(game) do
    fj_clue = Map.get(game.clues, "final_jeopardy")

    %{
      details: Drafts.change_game(game),
      jeopardy: %{
        categories: generate_category_changesets(game, :jeopardy),
        clues: generate_clue_changesets(game, :jeopardy)
      },
      double_jeopardy: %{
        categories: generate_category_changesets(game, :double_jeopardy),
        clues: generate_clue_changesets(game, :double_jeopardy)
      },
      final_jeopardy: Drafts.change_final_jeopardy_clue(%{}, fj_clue)
    }
  end
end
