defmodule JeopardyWeb.Components.Contestant.AwaitingFinalJeopardyWagers do
  use JeopardyWeb.FSMComponent
  alias Jeopardy.GameServer

  def assign_init(socket, game) do
    contestant = game.contestants[socket.assigns.name]
    score = contestant.score
    wager = contestant.final_jeopardy_wager

    {:ok,
     assign(socket,
       score: score,
       has_submitted_wager?: wager != nil,
       amount_wagered: wager,
       time_left: DateTime.diff(game.fsm.data.expires_at, DateTime.utc_now(), :millisecond),
       form: %{wager: wager}
     )}
  end

  def render(assigns) do
    ~H"""
    <div>
      <div :if={!@has_submitted_wager?}>
        <h3>Place wager</h3>
        <.form for={@form} phx-change="validate" phx-submit="submit" phx-target={@myself}>
          <.input type="number" field={@form[:wager]} max={@score} />
          <button class="btn btn-primary">Submit</button>
        </.form>
      </div>

      <div :if={@has_submitted_wager?}>
        <p>$<%= @amount_wagered %> is locked in.</p>
        <p>Waiting for others to finish submitting their wagers.</p>
      </div>
    </div>
    """
  end

  def handle_event("submit", %{"wager" => amount}, socket) do
    with {:ok, _game} <- GameServer.action(socket.assigns.code, :wagered, amount) do
      {:ok, assign(socket, has_submitted_wager?: true, amount_wagered: amount)}
    else
      _ -> {:ok, socket}
    end
  end

  def handle_game_server_msg({:wager_submitted, _name}, socket) do
    {:ok, socket}
  end
end
