defmodule JeopardyWeb.Components.Contestant.AwaitingFinalJeopardyWagers do
  use JeopardyWeb.FSMComponent
  alias Jeopardy.GameServer
  alias Jeopardy.Timers

  def assign_init(socket, game) do
    contestant = game.contestants[socket.assigns.name]
    score = contestant.score
    wager = contestant.final_jeopardy_wager

    assign(socket,
      score: score,
      has_submitted_wager?: wager != nil,
      amount_wagered: wager,
      time_remaining: Timers.time_remaining(game.fsm.data[:expires_at]),
      form: to_form(%{"wager" => wager})
    )
  end

  def render(assigns) do
    ~H"""
    <div>
      <div :if={not @has_submitted_wager?}>
        <h3>Place wager</h3>
        <.form for={@form} phx-change="validate" phx-submit="submit" phx-target={@myself}>
          <.input type="number" field={@form[:wager]} max={@score} />
          <button class="btn btn-primary">Submit</button>
        </.form>
        <.pie_timer time_remaining={@time_remaining} />
      </div>

      <div :if={@has_submitted_wager?}>
        <p>$<%= @amount_wagered %> is locked in.</p>
        <p>Waiting for others to finish submitting their wagers.</p>
      </div>
    </div>
    """
  end

  def handle_game_server_msg({:wager_submitted, name}, socket) do
    if name == socket.assigns.name,
      do: {:ok, assign(socket, has_submitted_wager?: true)},
      else: {:ok, socket}
  end

  def handle_event("submit", %{"wager" => wager}, socket) do
    with :ok <- validate(wager, 0..socket.assigns.score),
         {wager, _} = Integer.parse(wager) do
      GameServer.action(socket.assigns.code, :wagered, {socket.assigns.name, wager})
      {:noreply, assign(socket, has_submitted_wager?: true, amount_wagered: wager)}
    else
      {:error, msg} ->
        form = to_form(%{"wager" => wager}, errors: [wager: {msg, []}])
        {:noreply, assign(socket, form: form)}
    end
  end

  def handle_event("validate", %{"wager" => wager}, socket) do
    case validate(wager, 0..socket.assigns.score) do
      :ok ->
        {:noreply, socket}

      {:error, msg} ->
        form = to_form(%{"wager" => wager}, errors: [wager: {msg, []}])
        {:noreply, assign(socket, form: form)}
    end
  end

  defp validate(wager, min..max = range) do
    with {wager, _} <- Integer.parse(wager),
         true <- wager in range do
      :ok
    else
      _ -> {:error, "Must be between $#{min} and #{max}"}
    end
  end
end
