defmodule JeopardyWeb.Components.Trebek.AwaitingDailyDoubleWager do
  use JeopardyWeb.FSMComponent
  alias Jeopardy.GameServer

  def assign_init(socket, _game) do
    contestant = socket.assigns.game.contestants[socket.assigns.game.board_control]
    score = contestant.score

    {min_wager, max_wager} =
      if socket.assigns.game.round == :jeopardy,
        do: {5, max(score, 1_000)},
        else: {10, max(score, 2_000)}

    assign(socket,
      form: to_form(%{}),
      min_wager: min_wager,
      max_wager: max_wager
    )
  end

  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} phx-change="validate" phx-submit="submit" phx-target={@myself}>
        <.input type="text" field={@form[:wager]} placeholder={@max_wager} />
        <.button class="btn-primary">Submit Wager</.button>
      </.form>
    </div>
    """
  end

  def handle_event("submit", %{"wager" => wager} = params, socket) do
    with :ok <- validate(wager, socket.assigns.min_wager..socket.assigns.max_wager),
         {wager, _} = Integer.parse(wager) do
      GameServer.action(socket.assigns.code, :wagered, wager)
      {:noreply, assign(socket, form: to_form(params))}
    else
      {:error, msg} ->
        form = to_form(params, errors: [wager: {msg, []}])
        {:noreply, assign(socket, form: form)}
    end
  end

  def handle_event("validate", %{"wager" => wager} = params, socket) do
    case validate(wager, socket.assigns.min_wager..socket.assigns.max_wager) do
      :ok ->
        {:noreply, assign(socket, form: to_form(params))}

      {:error, msg} ->
        form = to_form(params, errors: [wager: {msg, []}])
        {:noreply, assign(socket, form: form)}
    end
  end

  def handle_game_server_msg({:wager_submitted, {_name, _amount}}, socket) do
    # {:ok, assign(socket, contestants: Map.put(socket.assigns.contestants, name, amount))}
    {:ok, socket}
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
