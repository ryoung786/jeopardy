defmodule JeopardyWeb.Components.Contestant.ReadingFinalJeopardyClue do
  use JeopardyWeb.FSMComponent
  alias Jeopardy.GameServer
  alias Jeopardy.Timers

  def assign_init(socket, game) do
    contestant = game.contestants[socket.assigns.name]
    time_remaining = Timers.time_remaining(game.fsm.data[:expires_at])

    assign(socket,
      form: to_form(%{"answer" => contestant.final_jeopardy_answer}),
      has_submitted_answer?: contestant.final_jeopardy_answer != nil,
      answer: contestant.final_jeopardy_answer,
      time_remaining: time_remaining
    )
  end

  def render(assigns) do
    ~H"""
    <div>
      <div :if={not @has_submitted_answer?}>
        <.form for={@form} phx-submit="submit" phx-target={@myself}>
          <.input type="text" field={@form[:answer]} placeholder="Answer" />
          <button class="btn btn-primary">Submit</button>
        </.form>

        <.pie_timer :if={@time_remaining} timer={60_000} time_remaining={@time_remaining} />
      </div>

      <div :if={@has_submitted_answer?}>
        <h3><%= @answer %></h3>
        <p>Your answer is locked in.</p>
        <p>Waiting for others to finish submitting their wagers.</p>
      </div>
    </div>
    """
  end

  def handle_event("submit", %{"answer" => answer}, socket) do
    with {:ok, _game} <-
           GameServer.action(socket.assigns.code, :answered, {socket.assigns.name, answer}) do
      {:ok, assign(socket, has_submitted_answer?: true, answer: answer)}
    else
      _ -> {:ok, socket}
    end
  end

  def handle_game_server_msg({:timer_started, expires_at}, socket) do
    {:ok, assign(socket, time_remaining: Timers.time_remaining(expires_at))}
  end
end
