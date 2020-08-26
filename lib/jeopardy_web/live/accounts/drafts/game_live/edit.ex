defmodule JeopardyWeb.Accounts.Drafts.GameLive.Edit do
  use JeopardyWeb, :live_view
  alias Jeopardy.Drafts
  alias Jeopardy.Drafts.Game
  require Logger

  @impl true
  def mount(%{"id" => id} = _params, %{"current_user_id" => current_user_id}, socket) do
    user = Jeopardy.Users.get_user!(current_user_id)
    round = "details"
    game = Drafts.get_game!(id)
    toc_links = toc_links_for_round(game, round)
    cs = all_changesets(game)

    {:ok,
     socket
     |> assign(current_user: user)
     |> assign(game: game)
     |> assign(toc_links: toc_links)
     |> assign(cs: cs)
     |> assign(active_tab: round)}
  end

  @impl true
  def handle_params(%{"round" => round}, _url, socket)
      when round in ~w(details jeopardy double-jeopardy final-jeopardy),
      do: {:noreply, assign(socket, active_tab: String.replace(round, "-", "_"))}

  @impl true
  def handle_params(%{"id" => id}, url, socket),
    do: handle_params(%{"id" => id, "round" => "details"}, url, socket)

  @impl true
  def handle_event("update-details", %{"details" => params}, socket) do
    params =
      Map.update!(
        params,
        "tags",
        fn str -> String.split(str, ",", trim: true) |> Enum.map(&String.trim/1) end
      )

    case Drafts.update_game(socket.assigns.game, params) do
      {:ok, game} ->
        {:noreply,
         assign(socket, game: game, cs: %{socket.assigns.cs | details: Drafts.change_game(game)})}

      {:error, cs} ->
        {:noreply, assign(socket, cs: %{socket.assigns.cs | details: cs})}
    end
  end

  @impl true
  def handle_event("update-category", all_params, socket) do
    key = Map.keys(all_params) |> Enum.find(fn key -> String.starts_with?(key, "category") end)
    params = Map.get(all_params, key)

    id = String.to_integer(params["id"])
    round = params["round"]
    id_all = if round == "jeopardy", do: id, else: id + 6

    changes =
      Drafts.get_category!(socket.assigns.game, id_all)
      |> Drafts.change_category(params)

    should_push = changes.changes |> Enum.empty?() |> Kernel.not()

    case Drafts.update_category(socket.assigns.game, id_all, %{}, params) do
      {:ok, game} ->
        {:noreply,
         socket
         |> maybe_push_js_event(should_push, round |> String.to_atom(), id)
         |> assign(game: game)
         |> assign(toc_links: toc_links_for_round(game, round))
         |> assign(cs: all_changesets(game))}

      {:error, cs} ->
        %{assigns: %{cs: all}} =
          update_in(
            socket.assigns.cs[String.to_atom(round)][:categories],
            &List.replace_at(&1, id, cs)
          )

        {:noreply, assign(socket, cs: all)}
    end
  end

  @impl true
  def handle_event("update-clue", all_params, socket) do
    key = Map.keys(all_params) |> Enum.find(fn key -> String.starts_with?(key, "clue") end)
    params = Map.get(all_params, key)

    id = String.to_integer(params["id"])
    category_id = String.to_integer(params["category_id"])
    round = String.to_atom(params["round"])
    changed_field = all_params["_target"] |> Enum.at(1)
    changed_field_params = Map.take(params, [changed_field])
    should_push_draft_saved = should_push_js_event(socket.assigns.game, id, changed_field_params)

    case Drafts.update_clue(socket.assigns.game, id, changed_field_params) do
      {:ok, game} ->
        cs = Drafts.get_clue!(game, id) |> Drafts.change_clue(params) |> Map.put(:action, :saved)
        all_changesets = update_clue_changeset(socket, round, id, cs)

        {:noreply,
         socket
         |> maybe_push_js_event(should_push_draft_saved, round, category_id)
         |> assign(game: game, cs: all_changesets)}

      {:error, cs} ->
        all_changesets = update_clue_changeset(socket, round, id, cs)
        {:noreply, assign(socket, cs: all_changesets)}
    end
  end

  @impl true
  def handle_event("update-final-jeopardy", %{"final_jeopardy" => params}, socket) do
    case Drafts.update_final_jeopardy_clue(socket.assigns.game, params) do
      {:ok, game} ->
        fj_clue = Map.get(game.clues, "final_jeopardy")

        {:noreply,
         assign(socket,
           game: game,
           cs: %{
             socket.assigns.cs
             | final_jeopardy: Drafts.change_final_jeopardy_clue(%{}, fj_clue)
           }
         )}

      {:error, cs} ->
        {:noreply, assign(socket, cs: %{socket.assigns.cs | final_jeopardy: cs})}
    end
  end

  defp toc_links_for_round(%Game{} = game, round) do
    case round do
      "details" ->
        [%{link: "general_info", text: "General Info"}]

      "jeopardy" ->
        toc_categories(game, round)

      "double_jeopardy" ->
        toc_categories(game, round)

      "final_jeopardy" ->
        [
          %{link: "category", text: "Category"},
          %{link: "clue", text: "Clue"},
          %{link: "answer", text: "Answer"}
        ]
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

  defp update_clue_changeset(socket, round, id, cs) do
    %{assigns: %{cs: all}} = put_in(socket.assigns.cs[round][:clues][id], cs)
    all
  end

  defp maybe_push_js_event(socket, should_push, round, category_id) do
    round = round |> Atom.to_string() |> String.replace("_", "-")

    if should_push,
      do: push_event(socket, "draft_saved", %{round: round, category_id: category_id}),
      else: socket
  end

  defp should_push_js_event(game, clue_id, params) do
    changes =
      Drafts.get_clue!(game, clue_id)
      |> Drafts.change_clue(params)

    changes.changes
    |> Enum.empty?()
    |> Kernel.not()
  end
end
