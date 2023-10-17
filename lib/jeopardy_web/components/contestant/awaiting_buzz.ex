defmodule JeopardyWeb.Components.Contestant.AwaitingBuzz do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  alias Jeopardy.GameServer

  def render(assigns) do
    ~H"""
    <div class="h-screen">
      <.button
        :if={@name not in @game.clue.incorrect_contestants}
        class="btn-primary rounded-none w-full h-full"
        phx-click="buzz"
        phx-target={@myself}
      >
        Buzz
      </.button>
      <.instructions :if={@name in @game.clue.incorrect_contestants}>
        You've already guessed incorrectly.<br /> Other contestants now have a chance to buzz in.
      </.instructions>
    </div>
    """
  end

  def handle_event("buzz", _params, socket) do
    case GameServer.action(socket.assigns.code, :buzz, socket.assigns.name) do
      {:ok, _game} -> {:noreply, socket}
      {:error, _} -> {:noreply, socket}
    end
  end
end
