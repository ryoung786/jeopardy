defmodule JeopardyWeb.TrebekLive do
  use JeopardyWeb, :live_view
  require Logger
  alias Jeopardy.Games.Game
  alias Jeopardy.Games
  alias JeopardyWeb.Presence

  @impl true
  def mount(%{"code" => code}, %{"name" => name}, socket) do
    game = Games.get_by_code(code)
    Presence.track(self(), code, name, %{name: name})

    case game.trebek do
      ^name ->
        if connected?(socket), do: Phoenix.PubSub.subscribe(Jeopardy.PubSub, code)

        socket =
          socket
          |> assign(name: name)
          |> assign(audience: Presence.list_presences(code))
          |> assign(component: component_from_game(game))
          |> assigns(game)

        {:ok, socket}

      _ ->
        {:ok, socket |> put_flash(:info, "Sorry, unauthorized") |> redirect(to: "/")}
    end
  end

  @impl true
  def render(assigns) do
    ~L"""
       <%= live_component(@socket, @component, render_assigns(assigns)) %>
    """
  end

  # @impl true
  # def handle_event("final_jeopardy_awaiting_answer_time_expired", _params, socket) do
  #   next_round(socket.assigns.game.code)
  #   {:noreply, socket}
  # end

  @impl true
  def handle_info(%{event: "presence_diff", payload: _payload}, socket) do
    {:noreply, assign(socket, audience: Presence.list_presences(socket.assigns.game.code))}
  end

  @impl true
  def handle_info(%{event: _} = data, socket) do
    component = component_from_game(socket.assigns.game)
    send_update(component, Map.put(data, :id, Atom.to_string(component)))
    {:noreply, socket}
  end

  @impl true
  # The db got updated, so let's query for the latest everything
  # and update our assigns
  def handle_info(_, socket), do: {:noreply, assigns(socket)}

  defp assigns(socket) do
    game = Games.get_by_code(socket.assigns.game.code)
    assigns(socket, game)
  end

  defp assigns(socket, %Game{} = game) do
    categories =
      if game.status == "jeopardy",
        do: game.jeopardy_round_categories,
        else: game.double_jeopardy_round_categories

    clues =
      if game.status == "jeopardy",
        do: Games.clues_by_category(game, :jeopardy),
        else: Games.clues_by_category(game, :double_jeopardy)

    clues =
      Enum.reduce(clues, %{}, fn [category: category, clues: clues], acc ->
        Map.put(acc, category, clues)
      end)

    socket
    |> assign(game: game)
    |> assign(component: component_from_game(game))
    |> assign(categories: categories)
    |> assign(clues: clues)
    |> assign(current_clue: Game.current_clue(game))
    |> assign(players: Games.get_just_contestants(game))
  end
end
