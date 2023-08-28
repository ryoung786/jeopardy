defmodule JeopardyWeb.HomeLive do
  use JeopardyWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}))}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} phx-submit="join" class="flex flex-col gap-4">
        <.input field={@form[:name]} placeholder="Name" />
        <.input field={@form[:room_code]} placeholder="ABCD" />
        <.button class="btn-primary">Join</.button>
      </.form>
      <p>Or</p>
      <.link class="btn btn-primary" phx-click="new_game">New Game</.link>
    </div>
    """
  end

  def handle_event("new_game", _data, socket) do
    code = Jeopardy.GameServer.new_game_server()
    {:noreply, push_navigate(socket, to: ~p"/games/#{code}")}
  end

  def handle_event("join", %{"name" => name, "room_code" => code} = form, socket) do
    case Jeopardy.GameServer.action(code, :add_player, name) do
      {:ok, _game} ->
        {:noreply, push_navigate(socket, to: ~p"/games/#{code}")}

      {:error, :game_not_found} ->
        form = to_form(form, errors: [room_code: {"Game does not exist", []}])
        {:noreply, assign(socket, form: form)}

      {:error, :invalid_action} ->
        form = to_form(form, errors: [room_code: {"Game is not accepting new players", []}])
        {:noreply, assign(socket, form: form)}

      {:error, :name_not_unique} ->
        form = to_form(form, errors: [name: {"Already taken, please use another name", []}])
        {:noreply, assign(socket, form: form)}
    end
  end
end
