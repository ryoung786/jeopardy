defmodule JeopardyWeb.Components.Trebek.GradingFinalJeopardyAnswers do
  use JeopardyWeb.FSMComponent
  alias Jeopardy.GameServer

  def assign_init(socket, game) do
    contestants =
      game.contestants |> Map.values() |> Map.new(&{&1.name, &1.final_jeopardy_answer})

    assign(socket,
      contestants: contestants,
      form: to_form(Map.new(contestants, fn {name, _} -> {name, _grade = false} end))
    )
  end

  def render(assigns) do
    ~H"""
    <div class="grid gap-4 grid-rows-[auto_1fr_auto] min-h-screen">
      <h3 class="bg-blue-800 text-neutral-100 text-shadow grid place-items-center text-2xl leading-snug p-4 text-center">
        Correct Response:<br />
        <%= @game.clue.answer %>
      </h3>
      <.form
        for={@form}
        class="max-w-screen-sm justify-self-center flex flex-col gap-4 p-4"
        phx-submit="submit"
        phx-target={@myself}
      >
        <div class="flex flex-col gap-2 items-start">
          <label
            :for={{name, answer} <- Enum.shuffle(@contestants)}
            for={"input-#{name}"}
            class="flex gap-4 cursor-pointer"
          >
            <input
              id={"input-#{name}"}
              type="checkbox"
              name="correct-responses[]"
              class="checkbox checkbox-success"
              value={name}
              checked={@form[name].value}
            />
            <%= answer %>
          </label>
        </div>
        <div>
          <.button class="btn-primary" type="submit">Submit</.button>
        </div>
      </.form>

      <.instructions full_width?={true}>
        Toggle all the correct answers, then press submit.
      </.instructions>
    </div>
    """
  end

  def handle_event("submit", params, socket) do
    correct_contestant_names = Map.get(params, "correct-responses", _default = [])
    GameServer.action(socket.assigns.code, :submitted_grades, correct_contestant_names)
    {:noreply, socket}
  end
end
