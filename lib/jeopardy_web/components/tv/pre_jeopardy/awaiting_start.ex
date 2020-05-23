defmodule JeopardyWeb.Components.TV.PreJeopardy.AwaitingStart do
  use JeopardyWeb.Components.Base, :tv
  alias Jeopardy.Games.Game
  alias Jeopardy.GameState

  @impl true
  def handle_event("start_game", _params, socket) do
    # guard if not enough players
    game = Jeopardy.JArchive.load_into_game(socket.assigns.game)
    socket.assigns.audience |> Enum.each(fn name -> add_player(game, name) end)
    GameState.update_round_status(game.code, "awaiting_start", "selecting_trebek")
    {:noreply, socket}
  end

  defp add_player(%Game{} = game, name) do
    Ecto.build_assoc(game, :players, %{name: name})
    |> Jeopardy.Repo.insert()
  end
end
