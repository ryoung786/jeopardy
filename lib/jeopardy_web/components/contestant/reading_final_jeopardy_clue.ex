defmodule JeopardyWeb.Components.Contestant.ReadingFinalJeopardyClue do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  alias Jeopardy.FSM.Messages.FinalJeopardyAnswerSubmitted
  alias Jeopardy.FSM.Messages.TimerStarted
  alias Jeopardy.GameServer
  alias Jeopardy.Timers

  def assign_init(socket, game) do
    contestant = game.contestants[socket.assigns.name]

    assign(socket,
      form: to_form(%{"answer" => contestant.final_jeopardy_answer}),
      has_submitted_answer?: contestant.final_jeopardy_answer != nil,
      answer: contestant.final_jeopardy_answer,
      expires_at: game.fsm.data[:expires_at]
    )
  end

  def render(assigns) do
    ~H"""
    <div>
      <div :if={@has_submitted_answer?} class="h-screen">
        <.instructions>
          <:additional>
            <div class="grid place-items-center mb-8">
              <div class="w-10 h-10">
                <.pie_timer
                  :if={@expires_at}
                  timer={60_000}
                  time_remaining={Timers.time_remaining(@expires_at)}
                  color="bg-primary"
                />
              </div>
            </div>
          </:additional>
          Your answer is locked in.<br /> Waiting for others to finish submitting their wagers.
        </.instructions>
      </div>

      <div
        :if={not @has_submitted_answer?}
        class="bg-sky-100 min-h-screen p-4 grid place-items-center"
      >
        <.form
          for={@form}
          class="flex flex-col gap-4 max-w-screen-sm w-full"
          phx-submit="submit"
          phx-target={@myself}
        >
          <div class="w-10 h-10 self-center">
            <.pie_timer
              :if={@expires_at}
              timer={60_000}
              time_remaining={Timers.time_remaining(@expires_at)}
              color="bg-primary"
            />
          </div>
          <.input type="text" field={@form[:answer]} placeholder="Answer" style="text-align: center" />
          <.button class="btn-primary">Submit</.button>
        </.form>
      </div>
    </div>
    """
  end

  def handle_event("submit", %{"answer" => answer} = params, socket) do
    answer = String.trim(answer)

    with :ok <- validate(answer),
         {:ok, _game} <-
           GameServer.action(socket.assigns.code, :answered, {socket.assigns.name, answer}) do
      {:noreply, assign(socket, has_submitted_answer?: true, answer: answer)}
    else
      {:error, msg} ->
        form = to_form(params, errors: [answer: {msg, []}])
        {:noreply, assign(socket, form: form)}

      _ ->
        {:noreply, assign(socket, form: to_form(params))}
    end
  end

  defp validate(answer) do
    if String.trim(answer) == "", do: {:error, "Cannot be blank."}, else: :ok
  end

  def handle_game_server_msg(%TimerStarted{expires_at: expires_at}, socket) do
    {:ok, assign(socket, expires_at: expires_at)}
  end

  def handle_game_server_msg(%FinalJeopardyAnswerSubmitted{}, socket) do
    {:ok, socket}
  end
end
