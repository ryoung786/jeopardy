defmodule JeopardyWeb.TrebekNextFinalJeopardyRevealComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML
  alias JeopardyWeb.TrebekNextFinalJeopardyRevealView
  alias Jeopardy.Games
  require Logger

  @impl true
  def render(assigns) do
    TrebekNextFinalJeopardyRevealView.render("trebek_next_final_jeopardy_reveal.html", assigns)
  end

  @impl true
  def update(assigns, socket) do
    socket = assign(socket, assigns)
    game = assigns.game

    next_player =
      case Games.contestants_yet_to_be_updated(game) do
        [next_player | _] -> next_player
        _ -> %{name: "wtf"}
      end

    socket =
      socket
      |> assign(contestant: socket.assigns[:contestant] || next_player)
      |> assign(step: :name)
      |> assign(cta: "Next")

    {:ok, socket}
  end

  @impl true
  def handle_event("next", _, socket) do
    player = socket.assigns.contestant
    game = socket.assigns.game
    cur_step = socket.assigns.step

    next_player =
      case cur_step do
        :next ->
          # update the player score and clue correct/incorrect list
          case socket.assigns.grade do
            :correct -> Games.final_jeopardy_correct_answer(game, player)
            :incorrect -> Games.final_jeopardy_incorrect_answer(game, player)
          end

          # update "revealed" on player
          # assign contestant to player with next lowest score
          case Games.contestants_yet_to_be_updated(game) do
            [next_player | _] -> next_player
            _ -> nil
          end

        _ ->
          player
      end

    next_step =
      %{
        name: :answer,
        answer: :grade,
        grade: :wager,
        wager: :next,
        next: :name
      }
      |> Map.get(cur_step)

    if is_nil(next_player) do
      Jeopardy.GameState.update_round_status(
        game.code,
        "revealing_final_scores",
        "game_over"
      )

      {:noreply, socket}
    else
      Phoenix.PubSub.broadcast(
        Jeopardy.PubSub,
        "#{game.code}-finaljeopardy",
        %{player: socket.assigns.contestant, step: cur_step}
      )

      socket =
        socket
        |> assign(step: next_step)
        |> assign(contestant: next_player)

      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("correct", _, socket) do
    {:noreply, assign(socket, grade: :correct, step: :wager)}
  end

  @impl true
  def handle_event("incorrect", _, socket) do
    {:noreply, assign(socket, grade: :incorrect, step: :wager)}
  end
end
